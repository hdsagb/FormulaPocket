import { PRIVACY_POLICY_TEXT } from '../model/PrivacyPolicy';

/**
 * 隐私政策卡片组件。
 * mode = 'consent'：首次启动同意弹窗（不同意并退出 / 同意并继续）
 * mode = 'view'：应用内查看浮层（我知道了）
 */
@Component
export struct PrivacyPolicySheet {
  @Prop mode: string = 'view';
  onAgree: () => void = () => {};
  onDisagree: () => void = () => {};
  onClose: () => void = () => {};

  build() {
    Column({ space: 14 }) {
      Text('隐私政策')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1F2430')

      Scroll() {
        Text(PRIVACY_POLICY_TEXT)
          .fontSize(13)
          .lineHeight(21)
          .fontColor('#3A4250')
      }
      .scrollBar(BarState.Auto)
      .layoutWeight(1)
      .align(Alignment.TopStart)

      if (this.mode === 'consent') {
        Row({ space: 12 }) {
          Button('不同意并退出')
            .fontSize(14)
            .backgroundColor('#EEF1F5')
            .fontColor('#5A6270')
            .layoutWeight(1)
            .onClick(() => {
              this.onDisagree();
            })
          Button('同意并继续')
            .fontSize(14)
            .backgroundColor('#4A6CF7')
            .fontColor(Color.White)
            .layoutWeight(1)
            .onClick(() => {
              this.onAgree();
            })
        }
        .width('100%')
      } else {
        Button('我知道了')
          .fontSize(14)
          .width('100%')
          .backgroundColor('#4A6CF7')
          .fontColor(Color.White)
          .onClick(() => {
            this.onClose();
          })
      }
    }
    .width('100%')
    .height('100%')
    .padding(20)
  }
}
