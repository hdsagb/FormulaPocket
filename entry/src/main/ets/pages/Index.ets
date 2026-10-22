/**
 * 主页（唯一页面）：
 * - 宽窗口（≥600vp）：左侧竖排科目导航 + 右侧公式卡片流（单页双栏）
 * - 窄窗口（<600vp）：导航折叠为顶部横排
 * - 顶部工具栏：App 名 + 搜索框（自动聚焦）
 * - 点击卡片弹出 bindSheet 详情浮层；收藏用 PersistentStorage 持久化
 */
import { Formula, FORMULAS, EMPTY_FORMULA, parseFavIds, toggleFavId, parseIdList, pushRecentId } from '../model/Formula';
import { PinyinEntry, buildPinyinMap } from '../model/PinyinIndex';
import { FormulaCard } from '../views/FormulaCard';
import { FormulaDetailSheet } from '../views/FormulaDetailSheet';
import { FlashcardView } from '../views/FlashcardView';
import { SettingsSheet } from '../views/SettingsSheet';
import { SCOPE_ALL, SCOPE_OPTIONS, inScope } from '../model/ScopeIndex';
import { applyThemeMode, THEME_SYSTEM } from '../model/Theme';
import { window, display } from '@kit.ArkUI';
import Context from '@ohos.app.ability.common';
import { KeyCode } from '@ohos.multimodalInput.keyCode';

interface Group {
  chapter: string;
  items: Formula[];
}

/** 列表行：章节标题行 或 公式行（用于键盘方向键精确选中与滚动定位） */
interface RowItem {
  isHeader: boolean;
  chapter: string;
  formula: Formula;
}

/** 搜索中间结果：先算分再排序，避免在比较器里重复计算 */
interface ScoredFormula {
  formula: Formula;
  score: number;
}

interface TabItem {
  label: string;
  key: string; // '' 表示「我的收藏」聚合视图；'recent' 表示最近浏览
}

const TABS: TabItem[] = [
  { label: '高等数学', key: '高数' },
  { label: '线性代数', key: '线代' },
  { label: '概率论', key: '概率论' },
  { label: '我的收藏', key: '' },
  { label: '最近', key: 'recent' }
];

// 收藏持久化：以 JSON 字符串存入 AppStorage，应用重启不丢
PersistentStorage.persistProp('favIds', '[]');
// 记住上次浏览的科目，重启后恢复
PersistentStorage.persistProp('lastTab', 0);
// 最近浏览的公式 id（最多 20 条）
PersistentStorage.persistProp('recentIds', '[]');
// 闪卡自测记录
PersistentStorage.persistProp('quizStats', '{}');
// 正文字号缩放（0.9 紧凑 / 1 标准 / 1.15 大）
PersistentStorage.persistProp('fontScale', 1);
// 考试范围：0 全部 / 1 数一 / 2 数二 / 3 数三
PersistentStorage.persistProp('examScope', SCOPE_ALL);
// 主题模式：system / light / dark
PersistentStorage.persistProp('themeMode', THEME_SYSTEM);

const WIDE_MIN_VP = 600;  // 断点：窗口宽 ≥600vp 用双栏
const SIDEBAR_WIDTH = 216;

@Entry
@Component
struct Index {
  @StorageLink('favIds') @Watch('onFilterChanged') favIds: string = '[]';
  @StorageLink('lastTab') @Watch('onFilterChanged') activeTab: number = 0;
  @StorageLink('recentIds') @Watch('onFilterChanged') recentIds: string = '[]';
  @State @Watch('onFilterChanged') keyword: string = '';
  @State isShowSheet: boolean = false;
  @State isShowSettings: boolean = false;
  @State isQuizShow: boolean = false;
  @State currentFormula: Formula = EMPTY_FORMULA;
  @State windowWidthVp: number = 1200;
  @State windowHeightVp: number = 800;
  @State selectedRow: number = -1;
  /** 搜索框是否持有焦点：持有时方向键归输入框，不做列表导航 */
  @State searchFocused: boolean = true;
  /** 考试范围：0 全部 / 1 数一 / 2 数二 / 3 数三 */
  @StorageLink('examScope') @Watch('onFilterChanged') examScope: number = SCOPE_ALL;
  /** 主题模式：system / light / dark */
  @StorageLink('themeMode') themeMode: string = THEME_SYSTEM;
  /** 当前列表行（章节标题 + 公式），仅在筛选条件变化时重算一次 */
  @State viewRows: RowItem[] = [];
  /** 收藏数量（避免侧边栏每帧重复解析收藏 JSON） */
  @State favCount: number = 0;

  private listScroller: Scroller = new Scroller();
  /** 自测题目来源（打开闪卡前确定） */
  private quizList: Formula[] = [];
  /** Ctrl 键是否按下（配合 Ctrl+F） */
  private ctrlHeld: boolean = false;

  private isWide(): boolean {
    return this.windowWidthVp >= WIDE_MIN_VP;
  }

  /** PC 键盘：Ctrl+F 聚焦搜索、↑↓ 选择结果、Enter 打开、Esc 关闭浮层 */
  private handleKeyEvent(event: KeyEvent): void {
    const isCtrl: boolean = event.keyCode === KeyCode.KEYCODE_CTRL_LEFT || event.keyCode === KeyCode.KEYCODE_CTRL_RIGHT;
    if (event.type === KeyType.Down) {
      if (isCtrl) {
        this.ctrlHeld = true;
        return;
      }
      if (event.keyCode === KeyCode.KEYCODE_F && this.ctrlHeld) {
        this.focusSearch();
        return;
      }
      // 有弹层时交给弹层自己处理（Esc 关闭由系统/子组件负责）
      if (this.isQuizShow || this.isShowSettings || this.isShowSheet) {
        return;
      }
      const code: number = event.keyCode;
      if (code === KeyCode.KEYCODE_ESCAPE) {
        this.selectedRow = -1;
        return;
      }
      // 搜索框聚焦时：↓ 进入列表导航（首次落到第一条），其余方向键归输入框
      if (this.searchFocused) {
        if (code === KeyCode.KEYCODE_DPAD_DOWN) {
          this.searchFocused = false;
          this.selectedRow = -1;
          this.stepSelected(1);
        }
        return;
      }
      if (code === KeyCode.KEYCODE_DPAD_UP) {
        this.stepSelected(-1);
      } else if (code === KeyCode.KEYCODE_DPAD_DOWN) {
        this.stepSelected(1);
      } else if (code === KeyCode.KEYCODE_ENTER || code === KeyCode.KEYCODE_NUMPAD_ENTER) {
        // 仅在列表中有选中项时打开，避免与搜索框提交、工具按钮的激活冲突
        if (this.selectedRow >= 0) {
          this.openSelectedOrFirst();
        }
      }
    } else if (event.type === KeyType.Up && isCtrl) {
      this.ctrlHeld = false;
    }
  }

  private focusSearch(): void {
    try {
      this.getUIContext().getFocusController().requestFocus('searchInput');
    } catch (err) {
      // 焦点目标不存在时忽略
    }
  }

  /** 在公式行之间上下移动选中项（跳过章节标题行），并滚动到可见 */
  private stepSelected(delta: number): void {
    const rows: RowItem[] = this.viewRows;
    if (rows.length === 0) {
      return;
    }
    let target: number = -1;
    if (this.selectedRow < 0) {
      if (delta > 0) {
        // 首次按下：落到第一条公式行
        for (let i = 0; i < rows.length; i++) {
          if (!rows[i].isHeader) {
            target = i;
            break;
          }
        }
      } else {
        // 首次按上：落到最后一条公式行
        for (let i = rows.length - 1; i >= 0; i--) {
          if (!rows[i].isHeader) {
            target = i;
            break;
          }
        }
      }
    } else {
      let j: number = this.selectedRow;
      while (true) {
        j = j + delta;
        if (j < 0 || j >= rows.length) {
          target = this.selectedRow; // 已到边界，保持不动
          break;
        }
        if (!rows[j].isHeader) {
          target = j;
          break;
        }
      }
    }
    if (target < 0) {
      return;
    }
    this.selectedRow = target;
    try {
      this.listScroller.scrollToIndex(target, true, ScrollAlign.AUTO);
    } catch (err) {
      // 滚动失败不影响选中
    }
  }

  /** 回车：打开选中项；未选中时打开首条结果 */
  private openSelectedOrFirst(): void {
    const rows: RowItem[] = this.viewRows;
    if (this.selectedRow >= 0 && this.selectedRow < rows.length && !rows[this.selectedRow].isHeader) {
      this.openDetail(rows[this.selectedRow].formula);
      return;
    }
    for (const r of rows) {
      if (!r.isHeader) {
        this.openDetail(r.formula);
        return;
      }
    }
  }

  /** 开始闪卡自测（题目来源＝当前 Tab 当前筛选结果） */
  private startQuiz(): void {
    const list: Formula[] = this.getFiltered();
    if (list.length === 0) {
      try {
        this.getUIContext().getPromptAction().showToast({ message: '当前列表没有可自测的公式', duration: 1500 });
      } catch (err) {
        // Toast 失败不影响主流程
      }
      return;
    }
    this.quizList = list;
    this.isQuizShow = true;
  }

  private switchTab(i: number): void {
    // activeTab 带 @Watch，赋值后会自动重算列表并清除选中项
    this.activeTab = i;
  }

  private isFavTab(): boolean {
    return TABS[this.activeTab].key === '';
  }

  private isRecentTab(): boolean {
    return TABS[this.activeTab].key === 'recent';
  }

  aboutToAppear(): void {
    // 先按当前筛选条件生成一次列表，后续只在条件变化时重算
    this.onFilterChanged();
    // getContext 已废弃，改用 UIContext 获取应用上下文
    const ctx: Context | undefined = this.getUIContext().getHostContext();
    // 恢复用户选择的主题（深色 / 浅色 / 跟随系统）
    applyThemeMode(ctx, this.themeMode);
    if (ctx === undefined) {
      return;
    }
    window.getLastWindow(ctx).then((win: window.Window) => {
      const rect: window.Rect = win.getWindowProperties().windowRect;
      this.updateSize(rect.width, rect.height);
      win.on('windowSizeChange', (size: window.Size) => {
        this.updateSize(size.width, size.height);
      });
    }).catch(() => {
      // 获取窗口失败时保持默认尺寸
    });
  }

  private updateSize(widthPx: number, heightPx: number): void {
    // 物理像素 -> vp（px2vp 已废弃，改用屏幕密度换算）
    try {
      const density: number = display.getDefaultDisplaySync().densityPixels;
      this.windowWidthVp = widthPx / density;
      this.windowHeightVp = heightPx / density;
    } catch (err) {
      // 显示信息不可用时按 2x 密度兜底（PC 常见值）
      this.windowWidthVp = widthPx / 2;
      this.windowHeightVp = heightPx / 2;
    }
  }

  /** 当前 Tab 的基础数据：科目 / 收藏 / 最近浏览，并叠加考试范围过滤 */
  private getBaseByTab(): Formula[] {
    const key: string = TABS[this.activeTab].key;
    let base: Formula[];
    if (key === '') {
      const favs: number[] = parseFavIds(this.favIds);
      base = FORMULAS.filter((f: Formula) => favs.includes(f.id));
    } else if (key === 'recent') {
      const ids: number[] = parseIdList(this.recentIds);
      const out: Formula[] = [];
      for (const id of ids) {
        const f: Formula | undefined = FORMULAS.find((x: Formula) => x.id === id);
        if (f !== undefined) {
          out.push(f);
        }
      }
      base = out;
    } else {
      base = FORMULAS.filter((f: Formula) => f.subject === key);
    }
    if (this.examScope === SCOPE_ALL) {
      return base;
    }
    return base.filter((f: Formula) => inScope(f.id, this.examScope));
  }

  /** 当前 Tab 的数据：科目过滤（或收藏/最近聚合）+ 关键词过滤 + 按相关度排序 */
  private getFiltered(): Formula[] {
    const base: Formula[] = this.getBaseByTab();
    const kw: string = this.keyword.trim().toLowerCase();
    if (kw.length === 0) {
      return base;
    }
    const frags: string[] = splitKwFrags(kw);
    // 先筛命中项并各算一次分，再排序（原写法在比较器里重复评分）
    const hitList: ScoredFormula[] = [];
    for (const f of base) {
      const cnHit: boolean = f.title.includes(kw) || f.formula.includes(kw) || f.condition.includes(kw);
      let matched: boolean = cnHit;
      if (!matched) {
        const e: PinyinEntry | undefined = this.pinyinMap.get(f.id);
        matched = e !== undefined && matchPinyinFrags(f.title, frags, e.py, e.sx);
      }
      if (matched) {
        hitList.push({ formula: f, score: this.searchScore(f, kw, frags) });
      }
    }
    hitList.sort((a: ScoredFormula, b: ScoredFormula) => b.score - a.score);
    const out: Formula[] = [];
    for (const s of hitList) {
      out.push(s.formula);
    }
    return out;
  }

  /** 搜索相关度评分：标题前缀 3 / 标题包含 2 / 内容或条件 1；拼音命中与中文同级，取较大者 */
  private searchScore(f: Formula, kw: string, frags: string[]): number {
    let cnScore = 0;
    if (f.title.startsWith(kw)) {
      cnScore = 3;
    } else if (f.title.includes(kw)) {
      cnScore = 2;
    } else if (f.formula.includes(kw) || f.condition.includes(kw)) {
      cnScore = 1;
    }
    const e: PinyinEntry | undefined = this.pinyinMap.get(f.id);
    if (e === undefined) {
      return cnScore;
    }
    // 纯拼音输入：首字母前缀 3 / 全拼或首字母包含 2；混合输入：片段全部命中 2
    let pyScore = 0;
    const cnFrags: string[] = frags.filter((x: string) => isCnChar(x.charAt(0)));
    const latinFrags: string[] = frags.filter((x: string) => !isCnChar(x.charAt(0)));
    if (latinFrags.length > 0) {
      if (latinFrags.length === 1 && e.sx.startsWith(latinFrags[0])) {
        pyScore = 3;
      } else if (latinFrags.every((x: string) => e.py.includes(x))
        && cnFrags.every((x: string) => f.title.includes(x))) {
        pyScore = 2;
      }
    }
    return Math.max(cnScore, pyScore);
  }

  private pinyinMap: Map<number, PinyinEntry> = buildPinyinMap();

  /** 按章节分组（保持 getFiltered 的排序结果，同章节需连续） */
  private getGroups(): Group[] {
    const base: Formula[] = this.getFiltered();
    const groups: Group[] = [];
    const byChapter: Map<string, Group> = new Map();
    for (const f of base) {
      const found: Group | undefined = byChapter.get(f.chapter);
      if (found !== undefined) {
        found.items.push(f);
      } else {
        const g: Group = { chapter: f.chapter, items: [f] };
        byChapter.set(f.chapter, g);
        groups.push(g);
      }
    }
    return groups;
  }

  /** 扁平化为列表行：每个章节前插一行标题行，便于键盘选中时精确滚动定位 */
  private buildRows(): RowItem[] {
    const groups: Group[] = this.getGroups();
    const rows: RowItem[] = [];
    for (const g of groups) {
      rows.push({ isHeader: true, chapter: g.chapter, formula: EMPTY_FORMULA });
      for (const f of g.items) {
        rows.push({ isHeader: false, chapter: '', formula: f });
      }
    }
    return rows;
  }

  /**
   * 筛选条件变化时统一重算列表：
   * Tab / 关键词 / 考试范围 / 收藏 / 最近浏览变化都会触发，build 中只读 viewRows。
   */
  private onFilterChanged(): void {
    this.favCount = parseFavIds(this.favIds).length;
    this.selectedRow = -1;
    this.viewRows = this.buildRows();
  }

  private openDetail(formula: Formula): void {
    this.currentFormula = formula;
    this.isShowSheet = true;
    // 记入最近浏览（去重 + 截断）
    this.recentIds = pushRecentId(this.recentIds, formula.id);
  }

  // ---------- 导航 ----------

  @Builder
  SideBar() {
    Column({ space: 6 }) {
      ForEach(TABS, (t: TabItem, i: number) => {
        Row({ space: 10 }) {
          if (t.key === '') {
            Text(this.favCount > 0 ? '★' : '☆')
              .fontSize(16)
              .fontColor(this.favCount > 0 ? $r('app.color.star') : $r('app.color.text_muted'))
          }
          Text(t.label)
            .fontSize(15)
            .maxLines(1)
            .fontColor(this.activeTab === i ? $r('app.color.accent') : $r('app.color.nav_text'))
            .fontWeight(this.activeTab === i ? FontWeight.Bold : FontWeight.Normal)
          Blank()
          if (t.key === '' && this.favCount > 0) {
            Text(this.favCount.toString())
              .fontSize(11)
              .fontColor($r('app.color.on_accent'))
              .padding({ left: 6, right: 6, top: 1, bottom: 1 })
              .borderRadius(999)
              .backgroundColor($r('app.color.star'))
          }
        }
        .width('100%')
        .padding({ left: 12, right: 12, top: 10, bottom: 10 })
        .borderRadius(10)
        .backgroundColor(this.activeTab === i ? $r('app.color.card_bg') : Color.Transparent)
        .hoverEffect(this.activeTab === i ? HoverEffect.None : HoverEffect.Highlight)
        .focusable(true)
        .onKeyEvent((e: KeyEvent) => {
          if (e.type === KeyType.Down && (e.keyCode === KeyCode.KEYCODE_ENTER || e.keyCode === KeyCode.KEYCODE_SPACE)) {
            this.switchTab(i);
          }
        })
        .onClick(() => {
          this.switchTab(i);
        })
      }, (t: TabItem) => t.label)

      Blank()

      Divider()
        .color($r('app.color.divider_strong'))
        .strokeWidth(1)

      Row({ space: 10 }) {
        Text('⚙')
          .fontSize(15)
          .fontColor($r('app.color.text_muted'))
        Text('设置')
          .fontSize(14)
          .fontColor($r('app.color.text_secondary'))
      }
      .width('100%')
      .padding({ left: 12, right: 12, top: 9, bottom: 9 })
      .borderRadius(10)
      .hoverEffect(HoverEffect.Highlight)
      .focusable(true)
      .onKeyEvent((e: KeyEvent) => {
        if (e.type === KeyType.Down && (e.keyCode === KeyCode.KEYCODE_ENTER || e.keyCode === KeyCode.KEYCODE_SPACE)) {
          this.isShowSettings = true;
        }
      })
      .onClick(() => {
        this.isShowSettings = true;
      })
    }
    .width(SIDEBAR_WIDTH)
    .height('100%')
    .padding(12)
    .backgroundColor($r('app.color.panel_bg'))
  }

  @Builder
  TopTabs() {
    Row({ space: 8 }) {
      ForEach(TABS, (t: TabItem, i: number) => {
        Text(t.label)
          .fontSize(13)
          .fontColor(this.activeTab === i ? $r('app.color.accent') : $r('app.color.text_secondary'))
          .fontWeight(this.activeTab === i ? FontWeight.Bold : FontWeight.Normal)
          .maxLines(1)
          .padding({ left: 10, right: 10, top: 6, bottom: 6 })
          .borderRadius(999)
          .backgroundColor(this.activeTab === i ? $r('app.color.accent_soft') : Color.Transparent)
          .focusable(true)
          .onKeyEvent((e: KeyEvent) => {
            if (e.type === KeyType.Down && (e.keyCode === KeyCode.KEYCODE_ENTER || e.keyCode === KeyCode.KEYCODE_SPACE)) {
              this.switchTab(i);
            }
          })
          .onClick(() => {
            this.switchTab(i);
          })
      }, (t: TabItem) => t.label)

      Blank()

      Text('⚙')
        .fontSize(15)
        .fontColor($r('app.color.text_secondary'))
        .padding({ left: 8, right: 8, top: 6, bottom: 6 })
        .borderRadius(6)
        .focusable(true)
        .onKeyEvent((e: KeyEvent) => {
          if (e.type === KeyType.Down && (e.keyCode === KeyCode.KEYCODE_ENTER || e.keyCode === KeyCode.KEYCODE_SPACE)) {
            this.isShowSettings = true;
          }
        })
        .onClick(() => {
          this.isShowSettings = true;
        })
    }
    .width('100%')
    .padding({ left: 12, right: 12, bottom: 8 })
  }

  // ---------- 内容区 ----------

  /** 考试范围筛选条：全部 / 数一 / 数二 / 数三 */
  @Builder
  ScopeBar() {
    Row({ space: 6 }) {
      Text('考试范围')
        .fontSize(12)
        .fontColor($r('app.color.text_muted'))
        .margin({ right: 2 })
      ForEach(SCOPE_OPTIONS, (label: string, i: number) => {
        Text(label)
          .fontSize(12)
          .fontColor(this.examScope === i ? $r('app.color.accent') : $r('app.color.text_secondary'))
          .fontWeight(this.examScope === i ? FontWeight.Bold : FontWeight.Normal)
          .padding({ left: 10, right: 10, top: 4, bottom: 4 })
          .borderRadius(999)
          .backgroundColor(this.examScope === i ? $r('app.color.accent_soft') : Color.Transparent)
          .hoverEffect(HoverEffect.Highlight)
          .focusable(true)
          .onKeyEvent((e: KeyEvent) => {
            if (e.type === KeyType.Down && (e.keyCode === KeyCode.KEYCODE_ENTER || e.keyCode === KeyCode.KEYCODE_SPACE)) {
              this.examScope = i;
            }
          })
          .onClick(() => {
            // 赋值后 @Watch 会重算列表并清除键盘选中
            this.examScope = i;
          })
      }, (label: string) => label)
      Blank()
    }
    .width('100%')
    .padding({ left: 16, right: 16, bottom: 6 })
  }

  @Builder
  FormulaGroupList() {
    List({ space: 12, scroller: this.listScroller }) {
      ForEach(this.viewRows, (row: RowItem, index: number) => {
        ListItem() {
          if (row.isHeader) {
            Text(row.chapter)
              .fontSize(14)
              .fontColor($r('app.color.text_secondary'))
              .width('100%')
          } else {
            FormulaCard({
              formula: row.formula,
              keyword: this.keyword,
              selected: this.selectedRow === index,
              onOpen: (formula: Formula) => {
                this.openDetail(formula);
              }
            })
          }
        }
      }, (row: RowItem, index: number) => row.isHeader ? ('h' + row.chapter) : ('f' + row.formula.id))
    }
    .width('100%')
    .layoutWeight(1)
    .padding({ left: 16, right: 16, top: 4, bottom: 24 })
    .scrollBar(BarState.Auto)
    .cachedCount(12)
  }

  /** 空态标题（按「范围 / 收藏 / 最近 / 搜索」优先级给出） */
  private emptyTitle(): string {
    if (this.keyword.trim().length > 0) {
      return '没有找到公式';
    }
    if (this.isFavTab()) {
      return '这里还是空的';
    }
    if (this.isRecentTab()) {
      return '这里还是空的';
    }
    if (this.examScope !== SCOPE_ALL) {
      return '当前考试范围下暂无公式';
    }
    return '没有找到公式';
  }

  /** 空态提示（与标题对应，给出下一步动作） */
  private emptyHint(): string {
    if (this.keyword.trim().length > 0) {
      return '换个关键词试试';
    }
    if (this.isFavTab()) {
      return '去列表里点亮 ☆ 收藏喜欢的公式吧';
    }
    if (this.isRecentTab()) {
      return '打开过的公式会出现在这里';
    }
    if (this.examScope !== SCOPE_ALL) {
      return '切换到「全部」范围看看';
    }
    return '换个关键词试试';
  }

  @Builder
  EmptyState() {
    Column({ space: 10 }) {
      Text(this.emptyTitle())
        .fontSize(16)
        .fontColor($r('app.color.text_muted'))
      Text(this.emptyHint())
        .fontSize(13)
        .fontColor($r('app.color.text_faint'))
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  ContentArea() {
    Column() {
      this.ScopeBar()
      if (this.viewRows.length === 0) {
        this.EmptyState()
      } else {
        this.FormulaGroupList()
      }
    }
    .width('100%')
    .height('100%')
    .layoutWeight(1)
    .onClick(() => {
      // 点击内容区即把焦点从搜索框移交给列表（键盘 ↑↓ 才生效）
      this.searchFocused = false;
    })
  }

  // ---------- 详情浮层 ----------

  @Builder
  SheetBuilder() {
    if (this.currentFormula.id >= 0) {
      FormulaDetailSheet({
        formula: this.currentFormula,
        onClose: () => {
          this.isShowSheet = false;
        }
      })
    } else {
      Column()
        .width(1)
        .height(1)
    }
  }

  // ---------- 设置面板 ----------

  @Builder
  SettingsBuilder() {
    SettingsSheet({
      onClose: () => {
        this.isShowSettings = false;
      }
    })
  }

  // ---------- 闪卡自测 ----------

  @Builder
  QuizBuilder() {
    FlashcardView({
      formulas: this.quizList,
      onExit: () => {
        this.isQuizShow = false;
      }
    })
  }

  build() {
    Stack() {
      Navigation() {
      Column() {
        // 顶部工具栏
        Row({ space: 12 }) {
          Text('口袋公式本')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.text_primary'))
            .maxLines(1)
          Blank()
          Text('开始自测')
            .fontSize(13)
            .fontColor($r('app.color.accent'))
            .maxLines(1)
            .padding({ left: 12, right: 12, top: 7, bottom: 7 })
            .backgroundColor($r('app.color.accent_soft'))
            .borderRadius(999)
            .hoverEffect(HoverEffect.Highlight)
            .focusable(true)
            .onKeyEvent((e: KeyEvent) => {
              if (e.type === KeyType.Down && (e.keyCode === KeyCode.KEYCODE_ENTER || e.keyCode === KeyCode.KEYCODE_SPACE)) {
                this.startQuiz();
              }
            })
            .onClick(() => {
              this.startQuiz();
            })
          Search({ value: this.keyword, placeholder: '搜索公式名 / 内容 / 条件' })
            .id('searchInput')
            .width(this.isWide() ? 260 : 150)
            .height(36)
            .onChange((value: string) => {
              this.keyword = value;
              this.selectedRow = -1; // 结果集变化，清除键盘选中
            })
            // 回车打开相关度最高的第一条结果
            .onSubmit(() => {
              const list: Formula[] = this.getFiltered();
              if (list.length > 0) {
                this.openDetail(list[0]);
              }
            })
            .onFocus(() => {
              this.searchFocused = true;
            })
            .onBlur(() => {
              this.searchFocused = false;
            })
            .defaultFocus(true)
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 14, bottom: 10 })

        // 主体：宽屏双栏 / 窄屏单栏
        Row() {
          if (this.isWide()) {
            this.SideBar()
            Divider()
              .vertical(true)
              .strokeWidth(1)
              .color($r('app.color.divider_strong'))
              .height('100%')
          }
          Column() {
            if (!this.isWide()) {
              this.TopTabs()
            }
            this.ContentArea()
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)
          .height('100%')
        }
        .layoutWeight(1)
        .width('100%')
        .alignItems(VerticalAlign.Top)
      }
      .width('100%')
      .height('100%')
      .bindSheet(this.isShowSettings, this.SettingsBuilder(), {
        // 按窗口高度取面板高度：窗口矮时留出滚动空间，避免内容被裁掉
        height: Math.min(560, Math.max(320, this.windowHeightVp - 80)),
        dragBar: false,
        showClose: false,
        onDisappear: () => {
          this.isShowSettings = false;
        }
      })
    }
    .mode(NavigationMode.Stack)
    .hideTitleBar(true)
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.page_bg'))
    .onKeyEvent((event: KeyEvent) => {
      this.handleKeyEvent(event);
    })
    .bindSheet(this.isShowSheet, this.SheetBuilder(), {
      height: SheetSize.FIT_CONTENT,
      dragBar: false,
      showClose: false,
      onDisappear: () => {
        this.isShowSheet = false;
        this.currentFormula = EMPTY_FORMULA;
      }
    })
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.page_bg'))
    .bindContentCover(this.isQuizShow, this.QuizBuilder(), {
      modalTransition: ModalTransition.DEFAULT,
      onDisappear: () => {
        this.isQuizShow = false;
      }
    })
  }
}

// ---------- 拼音搜索辅助 ----------

/** 是否为汉字 */
function isCnChar(ch: string): boolean {
  return ch >= '\u4e00' && ch <= '\u9fa5';
}

/** 是否为拉丁字母或数字（小写） */
function isLatinChar(ch: string): boolean {
  return (ch >= 'a' && ch <= 'z') || (ch >= '0' && ch <= '9');
}

/** 把关键词切分为连续中文段与连续拉丁段，如「泰勒gongshi」-> ['泰勒', 'gongshi'] */
function splitKwFrags(kw: string): string[] {
  const frags: string[] = [];
  let buf: string = '';
  let curCn: boolean = false;
  for (let i = 0; i < kw.length; i++) {
    const ch: string = kw.charAt(i);
    const cn: boolean = isCnChar(ch);
    const latin: boolean = isLatinChar(ch);
    if (!cn && !latin) {
      continue; // 符号（∫ 等）不参与拼音匹配，走中文全文分支
    }
    if (buf.length === 0 || cn === curCn) {
      buf += ch;
      curCn = cn;
    } else {
      frags.push(buf);
      buf = ch;
      curCn = cn;
    }
  }
  if (buf.length > 0) {
    frags.push(buf);
  }
  return frags;
}

/**
 * 拼音片段匹配：
 * - 中文段须全部出现在标题中（顺序无关，召回优先）
 * - 拉丁段须全部出现在全拼串或首字母串中
 * - 全拉丁单词也接受首字母串包含（tlgs -> 泰勒公式）
 */
function matchPinyinFrags(title: string, frags: string[], py: string, sx: string): boolean {
  let okTitle: boolean = true;
  let okPy: boolean = true;
  for (const frag of frags) {
    if (isCnChar(frag.charAt(0))) {
      if (!title.includes(frag)) {
        okTitle = false;
      }
    } else if (!py.includes(frag) && !sx.includes(frag)) {
      okPy = false;
    }
  }
  return okTitle && okPy;
}
