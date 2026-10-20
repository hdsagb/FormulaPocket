/**
 * 闪卡自测（全屏 bindContentCover）：
 * - 正面只显示「标题 + 章节」，用户先回想
 * - 空格 / 点击卡片显示答案；← 没记住，→ 记住了
 * - 结果写入 PersistentStorage('quizStats')，错题可一键重练
 * - Esc 退出
 */
import { Formula, EMPTY_FORMULA, addQuizStat } from '../model/Formula';
import { KeyCode } from '@ohos.multimodalInput.keyCode';

@Component
export struct FlashcardView {
  /** 本轮题目来源（由父组件在打开前确定） */
  formulas: Formula[] = [];
  onExit: () => void = () => {};

  @StorageLink('quizStats') quizStats: string = '{}';
  @StorageLink('fontScale') fontScale: number = 1;

  @State list: Formula[] = [];
  @State idx: number = 0;
  @State revealed: boolean = false;
  @State rightCount: number = 0;
  @State wrongCount: number = 0;
  @State wrongIds: number[] = [];
  @State finished: boolean = false;
  @State roundTotal: number = 0;

  aboutToAppear(): void {
    this.list = this.formulas.slice(0);
    this.roundTotal = this.list.length;
    if (this.list.length === 0) {
      this.onExit();
    }
  }

  private cur(): Formula {
    if (this.idx >= 0 && this.idx < this.list.length) {
      return this.list[this.idx];
    }
    return EMPTY_FORMULA;
  }

  /** 作答：ok=true 表示记住了 */
  private mark(ok: boolean): void {
    if (this.finished || this.list.length === 0) {
      return;
    }
    const f: Formula = this.cur();
    this.quizStats = addQuizStat(this.quizStats, f.id, ok);
    if (ok) {
      this.rightCount = this.rightCount + 1;
    } else {
      this.wrongCount = this.wrongCount + 1;
      this.wrongIds = this.wrongIds.concat([f.id]);
    }
    if (this.idx >= this.list.length - 1) {
      this.finished = true;
      this.revealed = false;
    } else {
      this.idx = this.idx + 1;
      this.revealed = false;
    }
  }

  /** 只重练本轮没记住的题 */
  private retryWrong(): void {
    const ids: number[] = this.wrongIds;
    const out: Formula[] = [];
    for (const f of this.list) {
      if (ids.includes(f.id)) {
        out.push(f);
      }
    }
    this.list = out;
    this.roundTotal = out.length;
    this.idx = 0;
    this.revealed = false;
    this.rightCount = 0;
    this.wrongCount = 0;
    this.wrongIds = [];
    this.finished = false;
  }

  private accuracy(): number {
    const total: number = this.rightCount + this.wrongCount;
    if (total === 0) {
      return 0;
    }
    return Math.round(this.rightCount * 100 / total);
  }

  private handleKey(event: KeyEvent): void {
    if (event.type !== KeyType.Down) {
      return;
    }
    const code: number = event.keyCode;
    if (code === KeyCode.KEYCODE_ESCAPE) {
      this.onExit();
      return;
    }
    if (this.finished) {
      if (code === KeyCode.KEYCODE_ENTER || code === KeyCode.KEYCODE_SPACE) {
        this.onExit();
      }
      return;
    }
    if (!this.revealed) {
      if (code === KeyCode.KEYCODE_SPACE || code === KeyCode.KEYCODE_ENTER) {
        this.revealed = true;
      }
      return;
    }
    if (code === KeyCode.KEYCODE_DPAD_LEFT || code === KeyCode.KEYCODE_1) {
      this.mark(false);
    } else if (code === KeyCode.KEYCODE_DPAD_RIGHT || code === KeyCode.KEYCODE_2) {
      this.mark(true);
    }
  }

  // ---------- UI ----------

  @Builder
  Header() {
    Row({ space: 12 }) {
      Text('闪卡自测')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1F2430')
      if (!this.finished && this.list.length > 0) {
        Text(`${this.idx + 1} / ${this.list.length}`)
          .fontSize(14)
          .fontColor('#5F6B7A')
      }
      Blank()
      Text('✕')
        .fontSize(20)
        .fontColor('#8A93A0')
        .padding(6)
        .onClick(() => {
          this.onExit();
        })
    }
    .width('100%')
  }

  @Builder
  QuestionCard() {
    Column({ space: 12 }) {
      Text(this.cur().subject + ' · ' + this.cur().chapter)
        .fontSize(13)
        .fontColor('#5F6B7A')
        .padding({ left: 10, right: 10, top: 4, bottom: 4 })
        .backgroundColor('#EEF2F7')
        .borderRadius(999)
      Text(this.cur().title)
        .fontSize(Math.round(34 * this.fontScale))
        .fontWeight(FontWeight.Bold)
        .fontColor('#1F2430')
        .textAlign(TextAlign.Center)
        .width('100%')
      if (!this.revealed) {
        Text('点击卡片或按空格显示答案')
          .fontSize(13)
          .fontColor('#A8B0BC')
      }
    }
    .width('100%')
    .padding({ top: 28, bottom: 28, left: 16, right: 16 })
    .backgroundColor('#FFFFFF')
    .borderRadius(16)
    .onClick(() => {
      if (!this.revealed) {
        this.revealed = true;
      }
    })
  }

  @Builder
  AnswerArea() {
    Column({ space: 10 }) {
      ForEach(this.cur().formula.split('\n'), (line: string, index: number) => {
        Text(line)
          .fontSize(Math.round(30 * this.fontScale))
          .fontWeight(FontWeight.Medium)
          .fontColor('#1F2430')
          .textAlign(TextAlign.Center)
          .copyOption(CopyOptions.InApp)
          .width('100%')
      }, (line: string, index: number) => index.toString() + line)

      Text('适用：' + this.cur().condition)
        .fontSize(13)
        .fontColor('#8A93A0')
        .textAlign(TextAlign.Center)
        .width('100%')
    }
    .width('100%')
    .padding({ top: 8, bottom: 8 })
  }

  @Builder
  ActionButtons() {
    Row({ space: 16 }) {
      Button('没记住  ←')
        .type(ButtonType.Normal)
        .fontSize(15)
        .fontColor('#3A4250')
        .backgroundColor('#EEF1F5')
        .borderRadius(12)
        .height(46)
        .layoutWeight(1)
        .onClick(() => {
          this.mark(false);
        })
      Button('记住了  →')
        .type(ButtonType.Normal)
        .fontSize(15)
        .fontColor('#FFFFFF')
        .backgroundColor('#2E6BE6')
        .borderRadius(12)
        .height(46)
        .layoutWeight(1)
        .onClick(() => {
          this.mark(true);
        })
    }
    .width('100%')
  }

  @Builder
  Summary() {
    Column({ space: 16 }) {
      Text('本轮完成')
        .fontSize(22)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1F2430')
      Text(`共 ${this.roundTotal} 条 · 记住 ${this.rightCount} · 没记住 ${this.wrongCount}`)
        .fontSize(15)
        .fontColor('#5F6B7A')
      Text(`${this.accuracy()}%`)
        .fontSize(40)
        .fontWeight(FontWeight.Bold)
        .fontColor('#2E6BE6')
      Text('正确率')
        .fontSize(13)
        .fontColor('#A8B0BC')

      Row({ space: 16 }) {
        if (this.wrongCount > 0) {
          Button('重练错题')
            .type(ButtonType.Normal)
            .fontSize(15)
            .fontColor('#2E6BE6')
            .backgroundColor('#E3EDFB')
            .borderRadius(12)
            .height(46)
            .layoutWeight(1)
            .onClick(() => {
              this.retryWrong();
            })
        }
        Button('完成')
          .type(ButtonType.Normal)
          .fontSize(15)
          .fontColor('#FFFFFF')
          .backgroundColor('#2E6BE6')
          .borderRadius(12)
          .height(46)
          .layoutWeight(1)
          .onClick(() => {
            this.onExit();
          })
      }
      .width('100%')
    }
    .width('100%')
    .padding({ top: 40, bottom: 40, left: 24, right: 24 })
    .backgroundColor('#FFFFFF')
    .borderRadius(16)
  }

  build() {
    Column({ space: 20 }) {
      this.Header()
      if (this.finished) {
        this.Summary()
      } else {
        this.QuestionCard()
        if (this.revealed) {
          this.AnswerArea()
          this.ActionButtons()
        } else {
          Blank()
        }
      }
    }
    .width('100%')
    .height('100%')
    .padding(28)
    .backgroundColor('#F7F8FA')
    .focusable(true)
    .defaultFocus(true)
    .onKeyEvent((event: KeyEvent) => {
      this.handleKey(event);
    })
  }
}
