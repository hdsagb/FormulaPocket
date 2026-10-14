/**
 * 公式卡片：列表页使用。
 * 收藏状态通过 @StorageLink 与 AppStorage('favIds') 双向同步，星标点击即时刷新。
 * 标题与正文区域点击打开详情；星标区域独立，两者互不影响。
 */
import { Formula, parseFavIds, toggleFavId } from '../model/Formula';

@Component
export struct FormulaCard {
  @Prop formula: Formula;
  /** 搜索关键词，用于标题命中高亮；为空时不高亮 */
  @Prop keyword: string = '';
  @StorageLink('favIds') favIds: string = '[]';
  /** 点击卡片主体时由父组件打开详情浮层 */
  onOpen: (formula: Formula) => void = () => {};

  private isFav(): boolean {
    return parseFavIds(this.favIds).includes(this.formula.id);
  }

  /** 标题中关键词首个命中位置（不区分大小写），未命中返回 -1 */
  private hitIndex(): number {
    if (this.keyword.length === 0) {
      return -1;
    }
    return this.formula.title.toLowerCase().indexOf(this.keyword.toLowerCase());
  }

  build() {
    Column({ space: 8 }) {
      Row({ space: 8 }) {
        if (this.hitIndex() >= 0) {
          // 命中：标题拆为 前段 + 命中段(高亮) + 后段
          Text() {
            Span(this.formula.title.substring(0, this.hitIndex()))
            Span(this.formula.title.substring(this.hitIndex(), this.hitIndex() + this.keyword.length))
              .fontColor('#2E6BE6')
              .fontWeight(FontWeight.Bolder)
            Span(this.formula.title.substring(this.hitIndex() + this.keyword.length))
          }
          .fontSize(17)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1F2430')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .layoutWeight(1)
          .onClick(() => {
            this.onOpen(this.formula);
          })
        } else {
          Text(this.formula.title)
            .fontSize(17)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1F2430')
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .layoutWeight(1)
            .onClick(() => {
              this.onOpen(this.formula);
            })
        }
        Text(this.isFav() ? '★' : '☆')
          .fontSize(20)
          .fontColor(this.isFav() ? '#F7B500' : '#B0B6BF')
          .onClick(() => {
            this.favIds = toggleFavId(this.favIds, this.formula.id);
          })
      }
      .width('100%')

      Column({ space: 8 }) {
        Text(this.formula.formula)
          .fontSize(16)
          .fontColor('#333B4A')
          .copyOption(CopyOptions.InApp)
          .width('100%')

        Text('适用：' + this.formula.condition)
          .fontSize(13)
          .fontColor('#8A93A0')
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
      }
      .width('100%')
      .onClick(() => {
        this.onOpen(this.formula);
      })
    }
    .padding(14)
    .borderRadius(12)
    .backgroundColor('#FFFFFF')
    .hoverEffect(HoverEffect.Highlight)
  }
}
