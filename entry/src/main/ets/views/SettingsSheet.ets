/**
 * 设置面板（bindSheet 半模态）：
 * - 字号缩放（紧凑 / 标准 / 大），持久化到 AppStorage('fontScale')
 * - 清除收藏、清除自测记录（数据均在本地）
 * - 关于：应用名与版本号
 */
import { bundleManager } from '@kit.AbilityKit';

@Component
export struct SettingsSheet {
  onClose: () => void = () => {};

  @StorageLink('favIds') favIds: string = '[]';
  @StorageLink('quizStats') quizStats: string = '{}';
  @StorageLink('fontScale') fontScale: number = 1;

  private versionName(): string {
    try {
      const info: bundleManager.BundleInfo =
        bundleManager.getBundleInfoForSelfSync(bundleManager.BundleFlag.GET_BUNDLE_INFO_DEFAULT);
      return info.versionName;
    } catch (err) {
      return '1.1.0';
    }
  }

  private toast(message: string): void {
    try {
      this.getUIContext().getPromptAction().showToast({ message: message, duration: 1500 });
    } catch (err) {
      // Toast 失败不影响主流程
    }
  }

  @Builder
  FontScaleOption(label: string, value: number) {
    Text(label)
      .fontSize(14)
      .fontColor(this.fontScale === value ? '#2E6BE6' : '#5F6B7A')
      .fontWeight(this.fontScale === value ? FontWeight.Bold : FontWeight.Normal)
      .textAlign(TextAlign.Center)
      .height(34)
      .layoutWeight(1)
      .borderRadius(9)
      .backgroundColor(this.fontScale === value ? '#E3EDFB' : Color.Transparent)
      .onClick(() => {
        this.fontScale = value;
      })
  }

  @Builder
  ActionRow(label: string, danger: boolean, action: () => void) {
    Text(label)
      .fontSize(15)
      .fontColor(danger ? '#D9483B' : '#3A4250')
      .width('100%')
      .padding({ top: 11, bottom: 11 })
      .hoverEffect(HoverEffect.Highlight)
      .borderRadius(9)
      .onClick(action)
  }

  build() {
    Column({ space: 14 }) {
      Row() {
        Text('设置')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1F2430')
        Blank()
        Text('✕')
          .fontSize(18)
          .fontColor('#8A93A0')
          .onClick(() => {
            this.onClose();
          })
      }
      .width('100%')

      // 字号
      Column({ space: 8 }) {
        Text('正文字号')
          .fontSize(13)
          .fontColor('#8A93A0')
          .width('100%')
        Row({ space: 6 }) {
          this.FontScaleOption('紧凑', 0.9)
          this.FontScaleOption('标准', 1)
          this.FontScaleOption('大', 1.15)
        }
        .width('100%')
      }
      .width('100%')
      .padding(14)
      .backgroundColor('#F7F8FA')
      .borderRadius(12)

      // 数据管理
      Column({ space: 2 }) {
        Text('数据管理')
          .fontSize(13)
          .fontColor('#8A93A0')
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
      .backgroundColor('#F7F8FA')
      .borderRadius(12)

      // 关于
      Column({ space: 6 }) {
        Text('关于')
          .fontSize(13)
          .fontColor('#8A93A0')
          .width('100%')
        Row() {
          Text('口袋公式本')
            .fontSize(15)
            .fontColor('#3A4250')
          Blank()
          Text('v' + this.versionName())
            .fontSize(14)
            .fontColor('#8A93A0')
        }
        .width('100%')
        Text('纯离线考研数学公式速查工具，不收集任何个人信息。')
          .fontSize(12)
          .fontColor('#A8B0BC')
          .width('100%')
      }
      .width('100%')
      .padding(14)
      .backgroundColor('#F7F8FA')
      .borderRadius(12)
    }
    .padding(24)
    .constraintSize({ minWidth: 420, maxWidth: 520 })
  }
}
