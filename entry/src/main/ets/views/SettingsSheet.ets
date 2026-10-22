/**
 * 设置面板（bindSheet 半模态）：
 * - 主题：跟随系统 / 浅色 / 深色，立即生效并持久化到 AppStorage('themeMode')
 * - 字号缩放（紧凑 / 标准 / 大），持久化到 AppStorage('fontScale')
 * - 清除收藏、清除自测记录（数据均在本地）
 * - 关于：应用名与版本号
 */
import { bundleManager, common } from '@kit.AbilityKit';
import { THEME_LABELS, THEME_OPTIONS, THEME_SYSTEM, applyThemeMode, saveThemeToPrefs } from '../model/Theme';

@Component
export struct SettingsSheet {
  onClose: () => void = () => {};

  @StorageLink('favIds') favIds: string = '[]';
  @StorageLink('quizStats') quizStats: string = '{}';
  @StorageLink('fontScale') fontScale: number = 1;
  @StorageLink('themeMode') themeMode: string = THEME_SYSTEM;

  private versionName(): string {
    try {
      const info: bundleManager.BundleInfo =
        bundleManager.getBundleInfoForSelfSync(bundleManager.BundleFlag.GET_BUNDLE_INFO_DEFAULT);
      return info.versionName;
    } catch (err) {
      return '—';
    }
  }

  private toast(message: string): void {
    try {
      this.getUIContext().getPromptAction().showToast({ message: message, duration: 1500 });
    } catch (err) {
      // Toast 失败不影响主流程
    }
  }

  /** 切换主题：写持久化 + 立即切换应用颜色模式 + 同步一份到 preferences（供冷启动提前生效） */
  private chooseTheme(mode: string): void {
    this.themeMode = mode;
    const ctx: common.Context | undefined = this.getUIContext().getHostContext();
    applyThemeMode(ctx, mode);
    saveThemeToPrefs(ctx, mode);
  }

  @Builder
  ThemeOption(label: string, mode: string) {
    Text(label)
      .fontSize(14)
      .fontColor(this.themeMode === mode ? $r('app.color.accent') : $r('app.color.text_secondary'))
      .fontWeight(this.themeMode === mode ? FontWeight.Bold : FontWeight.Normal)
      .textAlign(TextAlign.Center)
      .height(34)
      .layoutWeight(1)
      .borderRadius(9)
      .backgroundColor(this.themeMode === mode ? $r('app.color.accent_soft') : Color.Transparent)
      .onClick(() => {
        this.chooseTheme(mode);
      })
  }

  @Builder
  FontScaleOption(label: string, value: number) {
    Text(label)
      .fontSize(14)
      .fontColor(this.fontScale === value ? $r('app.color.accent') : $r('app.color.text_secondary'))
      .fontWeight(this.fontScale === value ? FontWeight.Bold : FontWeight.Normal)
      .textAlign(TextAlign.Center)
      .height(34)
      .layoutWeight(1)
      .borderRadius(9)
      .backgroundColor(this.fontScale === value ? $r('app.color.accent_soft') : Color.Transparent)
      .onClick(() => {
        this.fontScale = value;
      })
  }

  @Builder
  ActionRow(label: string, danger: boolean, action: () => void) {
    Text(label)
      .fontSize(15)
      .fontColor(danger ? $r('app.color.danger') : $r('app.color.nav_text'))
      .width('100%')
      .padding({ top: 11, bottom: 11 })
      .hoverEffect(HoverEffect.Highlight)
      .borderRadius(9)
      .onClick(action)
  }

  build() {
    // 包一层 Scroll：窗口较矮时（如 500vp 高的分屏窗口）内容可滚动，不会把「关于」区裁掉
    Scroll() {
      Column({ space: 14 }) {
        Row() {
          Text('设置')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.text_primary'))
          Blank()
          Text('✕')
            .fontSize(18)
            .fontColor($r('app.color.text_muted'))
            .onClick(() => {
              this.onClose();
            })
        }
        .width('100%')

      // 外观：主题 + 字号
      Column({ space: 8 }) {
        Text('主题')
          .fontSize(13)
          .fontColor($r('app.color.text_muted'))
          .width('100%')
        Row({ space: 6 }) {
          ForEach(THEME_OPTIONS, (mode: string, i: number) => {
            this.ThemeOption(THEME_LABELS[i], mode)
          }, (mode: string) => mode)
        }
        .width('100%')

        Text('正文字号')
          .fontSize(13)
          .fontColor($r('app.color.text_muted'))
          .width('100%')
          .margin({ top: 4 })
        Row({ space: 6 }) {
          this.FontScaleOption('紧凑', 0.9)
          this.FontScaleOption('标准', 1)
          this.FontScaleOption('大', 1.15)
        }
        .width('100%')
      }
      .width('100%')
      .padding(14)
      .backgroundColor($r('app.color.page_bg'))
      .borderRadius(12)

      // 数据管理
      Column({ space: 2 }) {
        Text('数据管理')
          .fontSize(13)
          .fontColor($r('app.color.text_muted'))
          .width('100%')
        this.ActionRow('清除全部收藏', true, () => {
          this.favIds = '[]';
          this.toast('已清除收藏');
        })
        this.ActionRow('清除自测记录', true, () => {
          this.quizStats = '{}';
          this.toast('已清除自测记录');
        })
      }
      .width('100%')
      .padding({ left: 14, right: 14, top: 10, bottom: 10 })
      .backgroundColor($r('app.color.page_bg'))
      .borderRadius(12)

      // 关于
      Column({ space: 6 }) {
        Text('关于')
          .fontSize(13)
          .fontColor($r('app.color.text_muted'))
          .width('100%')
        Row() {
          Text('口袋公式本')
            .fontSize(15)
            .fontColor($r('app.color.nav_text'))
          Blank()
          Text('v' + this.versionName())
            .fontSize(14)
            .fontColor($r('app.color.text_muted'))
        }
        .width('100%')
        Text('纯离线考研数学公式速查工具，不收集任何个人信息。')
          .fontSize(12)
          .fontColor($r('app.color.text_faint'))
          .width('100%')
      }
      .width('100%')
      .padding(14)
      .backgroundColor($r('app.color.page_bg'))
      .borderRadius(12)
      }
      .width('100%')
      .padding(24)
    }
    .width('100%')
    .height('100%')
    .scrollBar(BarState.Auto)
    .constraintSize({ minWidth: 420, maxWidth: 520 })
  }
}
