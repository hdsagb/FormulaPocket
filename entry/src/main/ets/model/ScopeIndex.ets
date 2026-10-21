/**
 * 考试范围（数一 / 数二 / 数三）：
 * 规则按考研数学大纲的科目边界划分，只列出「非通用」的公式 id，未列出的默认三科通用。
 * 这样维护成本最低：大纲微调时只需增减例外项，不必重排 120 条编号。
 *
 * 依据：
 * - 数二不考概率论与数理统计 → 概率论全部为「数一·数三」
 * - 数二不考无穷级数 → 级数相关为「数一·数三」
 * - 数三不考三重积分、曲线积分、曲面积分、傅里叶级数、曲率 → 这些为「数一」或「数一·数二」
 */

export const SCOPE_ALL: number = 0;
export const SCOPE_OPTIONS: string[] = ['全部', '数一', '数二', '数三'];
export const SCOPE_COMMON: string = '123';

/** 非通用项：id → 适用范围（'1' 数一 / '2' 数二 / '3' 数三 的组合） */
const SCOPE_EXCEPTIONS: Record<string, string> = {
  // 概率论与数理统计：数二不考 → 数一·数三
  '21': '13', '22': '13', '23': '13', '24': '13',
  '25': '13', '26': '13', '27': '13', '28': '13', '29': '13', '30': '13',
  '82': '13', '83': '13', '84': '13',
  '85': '13', '86': '13', '87': '13', '88': '13',
  '89': '13', '90': '13', '91': '13', '92': '13',
  '93': '13', '94': '13', '95': '13', '96': '13',
  '97': '13', '98': '13', '99': '13',
  '100': '13', '101': '13', '102': '13', '103': '13', '104': '13', '105': '13',
  '116': '13', '117': '13', '118': '13', '119': '13',
  // 无穷级数：数二不考 → 数一·数三
  '10': '13', '61': '13', '62': '13', '63': '13', '64': '13', '65': '13', '113': '13',
  // 仅数一：傅里叶级数、格林公式、高斯公式、三重积分、曲线积分
  '112': '1', '57': '1', '58': '1', '110': '1', '111': '1',
  // 数一·数二：曲率、可降阶的高阶方程（数三不考）
  '109': '12', '115': '12'
};

/** 取某条公式的适用范围；未列入例外表的按「三科通用」处理 */
export function scopeOf(id: number): string {
  const v: string | undefined = SCOPE_EXCEPTIONS[id.toString()];
  return v === undefined ? SCOPE_COMMON : v;
}

/** exam：1 数一 / 2 数二 / 3 数三；0 或非法值表示不过滤 */
export function inScope(id: number, exam: number): boolean {
  if (exam < 1 || exam > 3) {
    return true;
  }
  return scopeOf(id).includes(exam.toString());
}

/** 范围标签，如 '13' → 「数一·数三」，'123' → 「通用」 */
export function scopeLabel(id: number): string {
  const s: string = scopeOf(id);
  if (s === SCOPE_COMMON) {
    return '通用';
  }
  const names: string[] = [];
  if (s.includes('1')) {
    names.push('数一');
  }
  if (s.includes('2')) {
    names.push('数二');
  }
  if (s.includes('3')) {
    names.push('数三');
  }
  return names.join('·');
}
