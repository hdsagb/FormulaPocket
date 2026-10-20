/**
 * 详情浮层内容（bindSheet 半模态）：
 * 大字号公式居中展示，适合截图；带章节标签、收藏星标与关闭按钮。
 */
import { Formula, parseFavIds, toggleFavId } from '../model/Formula';
import { pasteboard } from '@kit.BasicServicesKit';

@Component
export struct FormulaDetailSheet {
  @Prop formula: Formula;
  @StorageLink('favIds') favIds: string = '[]';
  @StorageLink('fontScale') fontScale: number = 1;
  onClose: () => void = () => {};

  private isFav(): boolean {
    return parseFavIds(this.favIds).includes(this.formula.id);
  }

  /** 一键复制公式文本到系统剪贴板 */
  private copyFormula(): void {
    try {
      const pasteData: pasteboard.PasteData =
        pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, this.formula.formula);
      pasteboard.getSystemPasteboard().setData(pasteData).catch(() => {
        // 剪贴板写入失败时静默处理
      });
    } catch (err) {
      // 剪贴板服务不可用时静默处理
    }
    try {
      this.getUIContext().getPromptAction().showToast({ message: '公式已复制', duration: 1500 });
    } catch (err) {
      // Toast 失败不影响主流程
    }
  }

  build() {
    Column({ space: 12 }) {
      // 顶部：章节标签 + 星标 + 关闭
      Row({ space: 12 }) {
        Text(this.formula.subject + ' · ' + this.formula.chapter)
          .fontSize(14)
          .fontColor('#5F6B7A')
          .padding({ left: 10, right: 10, top: 4, bottom: 4 })
          .backgroundColor('#EEF2F7')
          .borderRadius(999)
        Blank()
        Text('复制')
          .fontSize(13)
          .fontColor('#2E6BE6')
          .padding({ left: 10, right: 10, top: 4, bottom: 4 })
          .backgroundColor('#E3EDFB')
          .borderRadius(999)
          .hoverEffect(HoverEffect.Highlight)
          .onClick(() => {
            this.copyFormula();
          })
        Text(this.isFav() ? '★' : '☆')
          .fontSize(24)
          .fontColor(this.isFav() ? '#F7B500' : '#B0B6BF')
          .onClick(() => {
            this.favIds = toggleFavId(this.favIds, this.formula.id);
          })
        Text('✕')
          .fontSize(18)
          .fontColor('#8A93A0')
          .onClick(() => {
            this.onClose();
          })
      }
      .width('100%')

      // 公式主体：按 \n 拆行、大字号居中
      Column({ space: 10 }) {
        ForEach(this.formula.formula.split('\n'), (line: string) => {
          Text(line)
            .fontSize(Math.round(32 * this.fontScale))
            .fontWeight(FontWeight.Medium)
            .fontColor('#1F2430')
            .textAlign(TextAlign.Center)
            .copyOption(CopyOptions.InApp)
            .width('100%')
        }, (line: string, index: number) => index.toString() + line)
      }
      .width('100%')
      .padding({ top: 16, bottom: 16 })

      Divider()
        .color('#E5E9F0')
        .width('100%')

      Text('适用条件：' + this.formula.condition)
        .fontSize(Math.round(15 * this.fontScale))
        .fontColor('#6B7482')
        .width('100%')
    }
    .padding(24)
    .constraintSize({ minWidth: 480, maxWidth: 720 })
  }
}
