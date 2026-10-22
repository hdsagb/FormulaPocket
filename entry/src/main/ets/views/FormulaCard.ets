/**
 * 公式卡片：列表页使用。
 * 收藏状态通过 @StorageLink 与 AppStorage('favIds') 双向同步，星标点击即时刷新。
 * 标题与正文区域点击打开详情；星标区域独立，两者互不影响。
 * 颜色全部取自 app.color.* 资源，浅色/深色模式自动切换。
 */
import { Formula, parseFavIds, toggleFavId } from '../model/Formula';

@Component
export struct FormulaCard {
  @Prop formula: Formula;
  /** 搜索关键词，用于标题命中高亮；为空时不高亮 */
  @Prop keyword: string = '';
  /** 键盘方向键选中态（PC 焦点高亮） */
  @Prop selected: boolean = false;
  @StorageLink('favIds') favIds: string = '[]';
  @StorageLink('fontScale') fontScale: number = 1;
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
              .fontColor($r('app.color.accent'))
              .fontWeight(FontWeight.Bolder)
            Span(this.formula.title.substring(this.hitIndex() + this.keyword.length))
          }
          .fontSize(Math.round(17 * this.fontScale))
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary'))
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .layoutWeight(1)
          // 卡片走 ↑↓ + Enter 的键盘路径，不参与 Tab 焦点序列，避免 Tab 穿过整列卡片
          .focusable(false)
          .onClick(() => {
            this.onOpen(this.formula);
          })
        } else {
          Text(this.formula.title)
            .fontSize(Math.round(17 * this.fontScale))
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.text_primary'))
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .layoutWeight(1)
            .focusable(false)
            .onClick(() => {
              this.onOpen(this.formula);
            })
        }
        Text(this.isFav() ? '★' : '☆')
          .fontSize(20)
          .fontColor(this.isFav() ? $r('app.color.star') : $r('app.color.star_off'))
          .focusable(false)
          .onClick(() => {
            this.favIds = toggleFavId(this.favIds, this.formula.id);
          })
      }
      .width('100%')

      Column({ space: 8 }) {
        Text(this.formula.formula)
          .fontSize(Math.round(16 * this.fontScale))
          .fontColor($r('app.color.text_body'))
          .copyOption(CopyOptions.InApp)
          .width('100%')

        Text('适用：' + this.formula.condition)
          .fontSize(Math.round(13 * this.fontScale))
          .fontColor($r('app.color.text_muted'))
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
      }
      .width('100%')
      .focusable(false)
      .onClick(() => {
        this.onOpen(this.formula);
      })
    }
    .padding(12)
    .border({ width: 2, color: this.selected ? $r('app.color.accent') : Color.Transparent, radius: 12 })
    .backgroundColor($r('app.color.card_bg'))
    .hoverEffect(HoverEffect.Highlight)
  }
}
