/**
 * 主页（唯一页面）：
 * - 宽窗口（≥600vp）：左侧竖排科目导航 + 右侧公式卡片流（单页双栏）
 * - 窄窗口（<600vp）：导航折叠为顶部横排
 * - 顶部工具栏：App 名 + 搜索框（自动聚焦）
 * - 点击卡片弹出 bindSheet 详情浮层；收藏用 PersistentStorage 持久化
 */
import { Formula, FORMULAS, EMPTY_FORMULA, parseFavIds, toggleFavId } from '../model/Formula';
import { FormulaCard } from '../views/FormulaCard';
import { FormulaDetailSheet } from '../views/FormulaDetailSheet';
import { PrivacyPolicySheet } from '../views/PrivacyPolicySheet';
import { window, display } from '@kit.ArkUI';
import { KeyCode } from '@ohos.multimodalInput.keyCode';

interface Group {
  chapter: string;
  items: Formula[];
}

interface TabItem {
  label: string;
  key: string; // '' 表示「我的收藏」聚合视图
}

const TABS: TabItem[] = [
  { label: '高等数学', key: '高数' },
  { label: '线性代数', key: '线代' },
  { label: '概率论', key: '概率论' },
  { label: '我的收藏', key: '' }
];

// 收藏持久化：以 JSON 字符串存入 AppStorage，应用重启不丢
PersistentStorage.persistProp('favIds', '[]');
// 记住上次浏览的科目，重启后恢复
PersistentStorage.persistProp('lastTab', 0);

const WIDE_MIN_VP = 600;  // 断点：窗口宽 ≥600vp 用双栏
const SIDEBAR_WIDTH = 216;

@Entry
@Component
struct Index {
  @StorageLink('favIds') favIds: string = '[]';
  @StorageLink('lastTab') activeTab: number = 0;
  @State keyword: string = '';
  @State isShowSheet: boolean = false;
  @State isShowPrivacy: boolean = false;
  @State currentFormula: Formula = EMPTY_FORMULA;
  @State windowWidthVp: number = 1200;

  private isWide(): boolean {
    return this.windowWidthVp >= WIDE_MIN_VP;
  }

  /** Ctrl+F 聚焦搜索框（PC 键盘快捷键） */
  private ctrlHeld: boolean = false;

  private handleKeyEvent(event: KeyEvent): void {
    const isCtrl: boolean = event.keyCode === KeyCode.KEYCODE_CTRL_LEFT || event.keyCode === KeyCode.KEYCODE_CTRL_RIGHT;
    if (event.type === KeyType.Down) {
      if (isCtrl) {
        this.ctrlHeld = true;
      } else if (event.keyCode === KeyCode.KEYCODE_F && this.ctrlHeld) {
        this.getUIContext().getFocusController().requestFocus('searchInput');
      }
    } else if (event.type === KeyType.Up && isCtrl) {
      this.ctrlHeld = false;
    }
  }

  private isFavTab(): boolean {
    return TABS[this.activeTab].key === '';
  }

  aboutToAppear(): void {
    window.getLastWindow(getContext(this)).then((win: window.Window) => {
      this.updateWidth(win.getWindowProperties().windowRect.width);
      win.on('windowSizeChange', (size: window.Size) => {
        this.updateWidth(size.width);
      });
    });
  }

  private updateWidth(widthPx: number): void {
    // 物理像素 -> vp（px2vp 已废弃，改用屏幕密度换算）
    this.windowWidthVp = widthPx / display.getDefaultDisplaySync().densityPixels;
  }

  /** 当前 Tab 的数据：科目过滤（或收藏聚合）+ 关键词过滤 + 按相关度排序 */
  private getFiltered(): Formula[] {
    const key: string = TABS[this.activeTab].key;
    let base: Formula[] = key === ''
      ? FORMULAS.filter((f: Formula) => parseFavIds(this.favIds).includes(f.id))
      : FORMULAS.filter((f: Formula) => f.subject === key);
    const kw: string = this.keyword.trim();
    if (kw.length > 0) {
      // 搜索范围：标题 / 公式内容 / 适用条件
      base = base.filter((f: Formula) =>
        f.title.includes(kw) || f.formula.includes(kw) || f.condition.includes(kw));
      // 相关度排序：标题前缀命中 > 标题命中 > 内容命中（同分保持原有顺序）
      base.sort((a: Formula, b: Formula) => this.searchScore(b, kw) - this.searchScore(a, kw));
    }
    return base;
  }

  /** 搜索相关度评分：标题前缀 3 / 标题包含 2 / 公式内容或条件命中 1 */
  private searchScore(f: Formula, kw: string): number {
    if (f.title.startsWith(kw)) {
      return 3;
    }
    if (f.title.includes(kw)) {
      return 2;
    }
    return 1;
  }

  /** 按章节分组（保持 getFiltered 的排序结果，同章节需连续） */
  private getGroups(): Group[] {
    const base: Formula[] = this.getFiltered();
    const groups: Group[] = [];
    for (const f of base) {
      const found: Group | undefined = groups.find((g: Group) => g.chapter === f.chapter);
      if (found !== undefined) {
        found.items.push(f);
      } else {
        const g: Group = { chapter: f.chapter, items: [f] };
        groups.push(g);
      }
    }
    return groups;
  }

  private openDetail(formula: Formula): void {
    this.currentFormula = formula;
    this.isShowSheet = true;
  }

  // ---------- 导航 ----------

  @Builder
  SideBar() {
    Column({ space: 6 }) {
      ForEach(TABS, (t: TabItem, i: number) => {
        Row({ space: 10 }) {
          if (t.key === '') {
            Text(parseFavIds(this.favIds).length > 0 ? '★' : '☆')
              .fontSize(16)
              .fontColor(parseFavIds(this.favIds).length > 0 ? '#F7B500' : '#8A93A0')
          }
          Text(t.label)
            .fontSize(15)
            .maxLines(1)
            .fontColor(this.activeTab === i ? '#2E6BE6' : '#3A4250')
            .fontWeight(this.activeTab === i ? FontWeight.Bold : FontWeight.Normal)
          Blank()
          if (t.key === '' && parseFavIds(this.favIds).length > 0) {
            Text(parseFavIds(this.favIds).length.toString())
              .fontSize(11)
              .fontColor('#FFFFFF')
              .padding({ left: 6, right: 6, top: 1, bottom: 1 })
              .borderRadius(999)
              .backgroundColor('#F7B500')
          }
        }
        .width('100%')
        .padding({ left: 12, right: 12, top: 10, bottom: 10 })
        .borderRadius(10)
        .backgroundColor(this.activeTab === i ? '#FFFFFF' : Color.Transparent)
        .hoverEffect(this.activeTab === i ? HoverEffect.None : HoverEffect.Highlight)
        .onClick(() => {
          this.activeTab = i;
        })
      }, (t: TabItem) => t.label)
      Blank()
      Divider()
        .color('#DDE3EC')
        .strokeWidth(1)
      Text('隐私政策')
        .fontSize(12)
        .fontColor('#8A93A0')
        .padding({ top: 6, bottom: 6 })
        .hoverEffect(HoverEffect.Highlight)
        .borderRadius(8)
        .onClick(() => {
          this.isShowPrivacy = true;
        })
    }
    .width(SIDEBAR_WIDTH)
    .height('100%')
    .padding(12)
    .backgroundColor('#EDF1F6')
    .bindSheet(this.isShowPrivacy, this.PrivacyViewBuilder(), {
      height: 560,
      dragBar: false,
      showClose: true,
      onDisappear: () => {
        this.isShowPrivacy = false;
      }
    })
  }

  @Builder
  PrivacyViewBuilder() {
    PrivacyPolicySheet({
      onClose: () => {
        this.isShowPrivacy = false;
      }
    })
  }

  @Builder
  TopTabs() {
    Row({ space: 8 }) {
      ForEach(TABS, (t: TabItem, i: number) => {
        Text(t.label)
          .fontSize(14)
          .fontColor(this.activeTab === i ? '#2E6BE6' : '#5F6B7A')
          .fontWeight(this.activeTab === i ? FontWeight.Bold : FontWeight.Normal)
          .padding({ left: 12, right: 12, top: 6, bottom: 6 })
          .borderRadius(999)
          .backgroundColor(this.activeTab === i ? '#E3EDFB' : Color.Transparent)
          .onClick(() => {
            this.activeTab = i;
          })
      }, (t: TabItem) => t.label)
    }
    .width('100%')
    .padding({ left: 12, right: 12, bottom: 8 })
  }

  // ---------- 内容区 ----------

  @Builder
  FormulaGroupList() {
    List({ space: 12 }) {
      ForEach(this.getGroups(), (g: Group) => {
        ListItem() {
          Column({ space: 12 }) {
            Text(g.chapter)
              .fontSize(14)
              .fontColor('#5F6B7A')
              .width('100%')
            ForEach(g.items, (f: Formula) => {
              FormulaCard({
                formula: f,
                keyword: this.keyword,
                onOpen: (formula: Formula) => {
                  this.openDetail(formula);
                }
              })
            }, (f: Formula) => f.id.toString())
          }
          .width('100%')
        }
      }, (g: Group) => g.chapter + g.items.length.toString())
    }
    .width('100%')
    .layoutWeight(1)
    .padding({ left: 16, right: 16, top: 4, bottom: 24 })
    .scrollBar(BarState.Auto)
    .cachedCount(6)
  }

  @Builder
  EmptyState() {
    Column({ space: 10 }) {
      Text('没有找到公式')
        .fontSize(16)
        .fontColor('#8A93A0')
      Text(this.isFavTab() && this.keyword.trim().length === 0
        ? '去列表里点亮 ☆ 收藏喜欢的公式吧'
        : '换个关键词试试')
        .fontSize(13)
        .fontColor('#A8B0BC')
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  ContentArea() {
    Column() {
      if (this.getGroups().length === 0) {
        this.EmptyState()
      } else {
        this.FormulaGroupList()
      }
    }
    .width('100%')
    .height('100%')
    .layoutWeight(1)
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

  build() {
    Stack() {
      Navigation() {
      Column() {
        // 顶部工具栏
        Row({ space: 12 }) {
          Text('口袋公式本')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1F2430')
            .maxLines(1)
          Blank()
          Search({ value: this.keyword, placeholder: '搜索公式名 / 内容 / 条件' })
            .id('searchInput')
            .width(260)
            .height(36)
            .onChange((value: string) => {
              this.keyword = value;
            })
            // 回车打开相关度最高的第一条结果
            .onSubmit(() => {
              const list: Formula[] = this.getFiltered();
              if (list.length > 0) {
                this.openDetail(list[0]);
              }
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
              .color('#E0E5EC')
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
    }
    .mode(NavigationMode.Stack)
    .hideTitleBar(true)
    .width('100%')
    .height('100%')
    .backgroundColor('#F7F8FA')
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
    .backgroundColor('#F7F8FA')
  }
}
