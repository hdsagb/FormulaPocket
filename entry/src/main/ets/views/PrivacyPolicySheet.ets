import { PRIVACY_POLICY_TEXT } from '../model/PrivacyPolicy';

/**
 * 隐私政策查看浮层（应用内侧栏入口）。
 * 首次启动的同意弹窗由华为「标准化隐私声明托管服务」在系统层提供，
 * 应用内不再自建首启弹窗，避免双重弹窗。
 */
@Component
export struct PrivacyPolicySheet {
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

      Button('我知道了')
        .fontSize(14)
        .width('100%')
        .backgroundColor('#4A6CF7')
        .fontColor(Color.White)
        .onClick(() => {
          this.onClose();
        })
    }
    .width('100%')
    .height('100%')
    .padding(20)
  }
}
