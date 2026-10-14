/**
 * 数据模型：考研数学公式
 */

export interface Formula {
  id: number;
  subject: '高数' | '线代' | '概率论'; // 科目
  chapter: string;   // 章节，如「一元微分」
  title: string;     // 公式名，如「洛必达法则」
  formula: string;   // 公式本体（Unicode 文本，\n 换行）
  condition: string; // 适用条件
}

/** 占位空公式（避免空值传参） */
export const EMPTY_FORMULA: Formula = {
  id: -1,
  subject: '高数',
  chapter: '',
  title: '',
  formula: '',
  condition: ''
};

/**
 * 收藏 id 集合以 JSON 字符串形式存储（PersistentStorage 仅稳定支持基础类型）。
 */
export function parseFavIds(favIds: string): number[] {
  try {
    return JSON.parse(favIds) as number[];
  } catch (err) {
    return [];
  }
}

/** 切换某条公式的收藏状态，返回新的 JSON 字符串 */
export function toggleFavId(favIds: string, id: number): string {
  const arr: number[] = parseFavIds(favIds);
  const idx: number = arr.indexOf(id);
  if (idx >= 0) {
    arr.splice(idx, 1);
  } else {
    arr.push(id);
  }
  return JSON.stringify(arr);
}

/**
 * 公式数据：共 105 条（高数 45 / 线代 26 / 概率论 34）。
 * - id 1~30 为初版数据，保持不变（兼容已收藏条目）
 * - 新增条目 id 从 31 起
 * - 数组按「科目 → 章节」聚合排序，保证列表分组连续
 * - 公式统一使用 Unicode 数学符号，\n 表示换行；标注「数一」等表示考试范围
 */
export const FORMULAS: Formula[] = [
  // ================= 高等数学（45 条） =================
  // ---- 极限 ----
  {
    id: 1, subject: '高数', chapter: '极限', title: '两个重要极限',
    formula: 'lim(x→0) sinx/x = 1\nlim(x→∞) (1+1/x)^x = e',
    condition: '第一个式子 x→0；第二个式子 x→∞'
  },
  {
    id: 2, subject: '高数', chapter: '极限', title: '洛必达法则',
    formula: 'lim f(x)/g(x) = lim f′(x)/g′(x)',
    condition: '0/0 或 ∞/∞ 型未定式，且导数比的极限存在'
  },
  {
    id: 3, subject: '高数', chapter: '极限', title: '等价无穷小替换',
    formula: 'sinx ~ x，tanx ~ x，arcsinx ~ x\nln(1+x) ~ x，e^x - 1 ~ x，(1+x)^a - 1 ~ ax（x→0）',
    condition: 'x→0 时使用，只能在乘除因子中替换'
  },
  {
    id: 31, subject: '高数', chapter: '极限', title: '极限四则运算法则',
    formula: 'lim [f(x) ± g(x)] = lim f(x) ± lim g(x)\nlim [f(x)·g(x)] = lim f(x) · lim g(x)',
    condition: '各极限均存在；商的法则要求分母极限 ≠ 0'
  },
  {
    id: 32, subject: '高数', chapter: '极限', title: '无穷小的比较',
    formula: 'lim α/β = 0：α 是 β 的高阶无穷小，记 α = o(β)\nlim α/β = c ≠ 0：同阶；lim α/β = 1：等价',
    condition: 'α、β 为同一极限过程下的无穷小'
  },
  {
    id: 33, subject: '高数', chapter: '极限', title: '夹逼准则',
    formula: 'g(x) ≤ f(x) ≤ h(x)，且 lim g(x) = lim h(x) = A\n则 lim f(x) = A',
    condition: '数列与函数两种形式均适用'
  },
  {
    id: 34, subject: '高数', chapter: '极限', title: '单调有界准则',
    formula: '单调递增有上界（或单调递减有下界）的数列必有极限',
    condition: '常用于递推数列 x_(n+1) = f(x_n) 的收敛性证明'
  },
  {
    id: 35, subject: '高数', chapter: '极限', title: '泰勒公式',
    formula: 'f(x) = ∑(k=0→n) f^(k)(x0)/k!·(x-x0)^k\n+ f^(n+1)(ξ)/(n+1)!·(x-x0)^(n+1)',
    condition: 'ξ 介于 x 与 x0 之间；此为带拉格朗日余项的形式'
  },
  {
    id: 36, subject: '高数', chapter: '极限', title: '常用麦克劳林展开',
    formula: 'e^x = 1 + x + x^2/2! + x^3/3! + …\nsinx = x - x^3/3! + x^5/5! - …\ncosx = 1 - x^2/2! + x^4/4! - …\nln(1+x) = x - x^2/2 + x^3/3 - …',
    condition: 'x→0；余项为 o(x^n)，求极限时按需取前几项'
  },
  {
    id: 37, subject: '高数', chapter: '极限', title: '1^∞ 型极限',
    formula: 'lim u(x)^v(x) = e^(lim [u(x) - 1]·v(x))',
    condition: 'u(x) → 1 且 v(x) → ∞ 的 1^∞ 型未定式'
  },
  {
    id: 38, subject: '高数', chapter: '极限', title: '渐近线',
    formula: '垂直：x = a（lim x→a f(x) = ∞）\n水平：y = b（lim x→∞ f(x) = b）\n斜：y = kx + b，k = lim f(x)/x，b = lim [f(x) - kx]',
    condition: '斜渐近线要求 k ≠ 0；同一方向水平与斜渐近线不能并存'
  },
  // ---- 一元微分 ----
  {
    id: 4, subject: '高数', chapter: '一元微分', title: '导数的定义',
    formula: 'f′(x0) = lim(h→0) [f(x0+h) - f(x0)]/h',
    condition: '左右极限存在且相等时才可导'
  },
  {
    id: 5, subject: '高数', chapter: '一元微分', title: '四则求导法则',
    formula: '(uv)′ = u′v + uv′\n(u/v)′ = (u′v - uv′)/v^2',
    condition: 'u、v 在该点均可导'
  },
  {
    id: 6, subject: '高数', chapter: '一元微分', title: '链式法则',
    formula: 'dy/dx = (dy/du)·(du/dx)',
    condition: '外层、内层函数均可导'
  },
  {
    id: 7, subject: '高数', chapter: '一元微分', title: '拉格朗日中值定理',
    formula: 'f(b) - f(a) = f′(ξ)(b - a)，ξ∈(a,b)',
    condition: 'f(x) 在 [a,b] 连续，在 (a,b) 内可导'
  },
  {
    id: 39, subject: '高数', chapter: '一元微分', title: '隐函数求导',
    formula: 'F(x, y) = 0 两边对 x 求导（y 视为 x 的函数）\n解出 y′ = -F_x/F_y',
    condition: 'F_y ≠ 0；与多元隐函数求导公式一致'
  },
  {
    id: 40, subject: '高数', chapter: '一元微分', title: '参数方程求导',
    formula: 'dy/dx = (dy/dt)/(dx/dt)\nd²y/dx² = d[(dy/dt)/(dx/dt)]/dt ÷ (dx/dt)',
    condition: 'dx/dt ≠ 0；二阶导易错，注意最后再除一次 dx/dt'
  },
  {
    id: 41, subject: '高数', chapter: '一元微分', title: '莱布尼茨公式',
    formula: '(uv)^(n) = ∑(k=0→n) C(n,k)·u^(n-k)·v^(k)',
    condition: 'u、v 均 n 阶可导；形式与二项式定理相同'
  },
  {
    id: 42, subject: '高数', chapter: '一元微分', title: '常见函数高阶导数',
    formula: '(e^(ax))^(n) = a^n·e^(ax)\n(sin ax)^(n) = a^n·sin(ax + nπ/2)\n(ln(1+x))^(n) = (-1)^(n-1)·(n-1)!/(1+x)^n',
    condition: '通项公式，代入 n 即得'
  },
  {
    id: 43, subject: '高数', chapter: '一元微分', title: '柯西中值定理',
    formula: '[f(b) - f(a)]/[g(b) - g(a)] = f′(ξ)/g′(ξ)，ξ∈(a,b)',
    condition: 'f、g 在 [a,b] 连续、(a,b) 内可导，且 g′(x) ≠ 0'
  },
  {
    id: 44, subject: '高数', chapter: '一元微分', title: '极值第二充分条件',
    formula: 'f′(x0) = 0 且 f″(x0) ≠ 0：\nf″(x0) < 0 取极大值；f″(x0) > 0 取极小值',
    condition: 'f″(x0) = 0 时失效，需改用第一充分条件（看两侧变号）'
  },
  // ---- 一元积分 ----
  {
    id: 8, subject: '高数', chapter: '一元积分', title: '牛顿-莱布尼茨公式',
    formula: '∫[a,b] f(x)dx = F(b) - F(a)',
    condition: 'F(x) 是 f(x) 在 [a,b] 上的一个原函数'
  },
  {
    id: 9, subject: '高数', chapter: '一元积分', title: '分部积分法',
    formula: '∫u dv = uv - ∫v du',
    condition: '按「反对幂指三」顺序选取 u'
  },
  {
    id: 45, subject: '高数', chapter: '一元积分', title: '基本积分表',
    formula: '∫x^a dx = x^(a+1)/(a+1) + C（a ≠ -1）\n∫1/x dx = ln|x| + C\n∫e^x dx = e^x + C，∫a^x dx = a^x/ln a + C\n∫cosx dx = sinx + C，∫sinx dx = -cosx + C',
    condition: '均需 + C；要求 a > 0 且 a ≠ 1'
  },
  {
    id: 46, subject: '高数', chapter: '一元积分', title: '换元积分法',
    formula: '∫f(φ(x))·φ′(x)dx = ∫f(u)du，u = φ(x)\n凑微分：∫f(ax+b)dx = (1/a)·∫f(u)du',
    condition: '第一类换元；定积分换元时上下限要同步替换'
  },
  {
    id: 47, subject: '高数', chapter: '一元积分', title: '定积分奇偶对称性',
    formula: '∫[-a,a] f(x)dx = 0（f 为奇函数）\n∫[-a,a] f(x)dx = 2∫[0,a] f(x)dx（f 为偶函数）',
    condition: '积分区间必须关于原点对称'
  },
  {
    id: 48, subject: '高数', chapter: '一元积分', title: '变限积分求导',
    formula: 'd/dx ∫[a,x] f(t)dt = f(x)\nd/dx ∫[φ(x),ψ(x)] f(t)dt = f(ψ)ψ′ - f(φ)φ′',
    condition: 'f 连续；上下限为复合函数时按链式法则'
  },
  {
    id: 49, subject: '高数', chapter: '一元积分', title: '积分中值定理',
    formula: '∫[a,b] f(x)dx = f(ξ)·(b - a)，ξ ∈ [a,b]',
    condition: 'f 在 [a,b] 上连续'
  },
  {
    id: 50, subject: '高数', chapter: '一元积分', title: '旋转体体积',
    formula: '绕 x 轴：V = π·∫[a,b] f²(x)dx\n绕 y 轴（柱壳法）：V = 2π·∫[a,b] x·f(x)dx',
    condition: 'f(x) 在 [a,b] 连续且非负'
  },
  {
    id: 51, subject: '高数', chapter: '一元积分', title: '平面曲线弧长',
    formula: '直角坐标：s = ∫[a,b] √(1 + f′²(x)) dx\n参数方程：s = ∫√(x′²(t) + y′²(t)) dt',
    condition: '曲线具有连续导数'
  },
  // ---- 多元微分 ----
  {
    id: 52, subject: '高数', chapter: '多元微分', title: '偏导数与全微分',
    formula: '∂f/∂x = lim(Δx→0) [f(x0+Δx, y0) - f(x0, y0)]/Δx\ndz = (∂z/∂x)dx + (∂z/∂y)dy',
    condition: '偏导连续 ⇒ 可微；可微 ⇒ 偏导存在（反向均不成立）'
  },
  {
    id: 53, subject: '高数', chapter: '多元微分', title: '多元复合链式法则',
    formula: 'z = f(x(t), y(t)) 时\ndz/dt = (∂z/∂x)·(dx/dt) + (∂z/∂y)·(dy/dt)',
    condition: '中间变量有多个时逐条相加，建议画链路图防漏项'
  },
  {
    id: 54, subject: '高数', chapter: '多元微分', title: '多元极值充分条件',
    formula: '记 A = f_xx，B = f_xy，C = f_yy：\nAC - B² > 0 且 A > 0：极小值；A < 0：极大值\nAC - B² < 0：不是极值',
    condition: '在驻点（f_x = f_y = 0）处判别；AC - B² = 0 时失效'
  },
  {
    id: 55, subject: '高数', chapter: '多元微分', title: '拉格朗日乘数法',
    formula: 'L(x, y, λ) = f(x, y) + λ·φ(x, y)\n令 L_x = 0，L_y = 0，L_λ = 0，解出的点即候选极值点',
    condition: '求 φ(x, y) = 0 约束下的条件极值'
  },
  // ---- 多元积分 ----
  {
    id: 56, subject: '高数', chapter: '多元积分', title: '二重积分计算',
    formula: '直角坐标：∬D f dσ = ∫dx ∫f(x, y)dy\n极坐标：∬D f dσ = ∫dθ ∫f(rcosθ, rsinθ)·r dr',
    condition: '极坐标适合圆域或含 x² + y² 的被积函数；注意别丢 r'
  },
  {
    id: 57, subject: '高数', chapter: '多元积分', title: '格林公式',
    formula: '∮L P dx + Q dy = ∬D (∂Q/∂x - ∂P/∂y) dσ',
    condition: '数一；L 为区域 D 的正向边界闭曲线，P、Q 偏导连续'
  },
  {
    id: 58, subject: '高数', chapter: '多元积分', title: '高斯公式',
    formula: '∬_Σ P dydz + Q dzdx + R dxdy\n= ∭Ω (∂P/∂x + ∂Q/∂y + ∂R/∂z) dV',
    condition: '数一；Σ 为闭曲面 Ω 的外侧'
  },
  // ---- 常微分方程 ----
  {
    id: 59, subject: '高数', chapter: '常微分方程', title: '一阶线性方程通解',
    formula: 'y′ + P(x)y = Q(x)\ny = e^(-∫P dx)·[∫Q(x)·e^(∫P dx)dx + C]',
    condition: '通解公式；Q = 0 时为齐次方程'
  },
  {
    id: 60, subject: '高数', chapter: '常微分方程', title: '二阶常系数线性方程',
    formula: 'y″ + py′ + qy = 0，特征根 r1, r2：\n异根：y = C1·e^(r1x) + C2·e^(r2x)\n重根：y = (C1 + C2x)·e^(rx)\n复根 α±βi：y = e^(αx)(C1·cosβx + C2·sinβx)\n非齐次特解设 y* = x^k·Q_m(x)·e^(λx)',
    condition: 'k 为 λ 作为特征根的重数（0、1 或 2）'
  },
  // ---- 级数 ----
  {
    id: 10, subject: '高数', chapter: '级数', title: '等比级数',
    formula: '∑(n=0→∞) a·q^n = a/(1-q)',
    condition: '|q| < 1 时收敛，|q| ≥ 1 时发散'
  },
  {
    id: 61, subject: '高数', chapter: '级数', title: 'p 级数与调和级数',
    formula: '∑1/n^p 收敛 ⇔ p > 1\n∑1/n（调和级数）发散',
    condition: '正项级数比较判别法的基准'
  },
  {
    id: 62, subject: '高数', chapter: '级数', title: '比值判别法',
    formula: 'lim(n→∞) a_(n+1)/a_n = ρ：\nρ < 1 收敛，ρ > 1 发散',
    condition: '正项级数；ρ = 1 时失效，改用比较判别法'
  },
  {
    id: 63, subject: '高数', chapter: '级数', title: '莱布尼茨判别法',
    formula: 'u_n 单调递减且 lim(n→∞) u_n = 0\n⇒ 交错级数 ∑(-1)^(n-1)·u_n 收敛',
    condition: '两条件缺一不可；余项估计 |r_n| ≤ u_(n+1)'
  },
  {
    id: 64, subject: '高数', chapter: '级数', title: '绝对收敛与条件收敛',
    formula: '∑|a_n| 收敛 ⇒ ∑a_n 收敛（绝对收敛）\n∑a_n 收敛但 ∑|a_n| 发散：条件收敛',
    condition: '判别顺序：先考察绝对值级数，再看原级数'
  },
  {
    id: 65, subject: '高数', chapter: '级数', title: '幂级数收敛半径',
    formula: 'ρ = lim(n→∞) |a_(n+1)/a_n|，R = 1/ρ\n收敛区间 (-R, R)，端点需单独判别',
    condition: 'ρ = 0 时 R = +∞；区间内绝对收敛（阿贝尔定理）'
  },
  // ================= 线性代数（26 条） =================
  // ---- 行列式 ----
  {
    id: 11, subject: '线代', chapter: '行列式', title: '行列式乘法性质',
    formula: '|AB| = |A|·|B|',
    condition: 'A、B 为同阶方阵'
  },
  {
    id: 12, subject: '线代', chapter: '行列式', title: '克拉默法则',
    formula: 'x_i = D_i/D（i = 1, 2, …, n）',
    condition: '系数行列式 D ≠ 0'
  },
  {
    id: 66, subject: '线代', chapter: '行列式', title: '按行（列）展开定理',
    formula: '|A| = ∑(j=1→n) a_ij·A_ij（按第 i 行展开）\n∑ a_ij·A_kj = 0（i ≠ k，异乘变零）',
    condition: 'A_ij 为代数余子式；异乘变零常用于递推计算'
  },
  {
    id: 67, subject: '线代', chapter: '行列式', title: '范德蒙德行列式',
    formula: 'n 阶范德蒙德行列式\n= ∏(1 ≤ i < j ≤ n) (a_j - a_i)',
    condition: '行为 a_i 的幂次，列标为幂指数'
  },
  {
    id: 68, subject: '线代', chapter: '行列式', title: '行列式基本性质',
    formula: '两行互换：|A| 变号\n某行乘 k：|A| 变为 k·|A|\n某行加上另一行的 k 倍：|A| 不变',
    condition: '倍加性质不改变值，是化三角形求值的首选'
  },
  // ---- 矩阵 ----
  {
    id: 13, subject: '线代', chapter: '矩阵', title: '逆矩阵公式',
    formula: 'A^(-1) = A*/|A|',
    condition: '|A| ≠ 0（A 为可逆 n 阶方阵）'
  },
  {
    id: 14, subject: '线代', chapter: '矩阵', title: '伴随矩阵性质',
    formula: 'AA* = A*A = |A|E',
    condition: 'A 为 n 阶方阵'
  },
  {
    id: 15, subject: '线代', chapter: '矩阵', title: '转置运算律',
    formula: '(AB)^T = B^T·A^T，(A^T)^T = A',
    condition: 'A 可左乘 B'
  },
  {
    id: 69, subject: '线代', chapter: '矩阵', title: '可逆的充要条件',
    formula: 'A 可逆 ⇔ |A| ≠ 0 ⇔ r(A) = n\n⇔ Ax = 0 只有零解 ⇔ A 的特征值全不为 0',
    condition: 'n 阶方阵；多条等价路径按题意选用'
  },
  {
    id: 70, subject: '线代', chapter: '矩阵', title: '秩的基本不等式',
    formula: 'r(AB) ≤ min[r(A), r(B)]\nr(A + B) ≤ r(A) + r(B)\nA 为 m×n，B 为 n×s 时：r(AB) ≥ r(A) + r(B) - n',
    condition: '最后一条为 Sylvester 不等式，常用于估计秩的范围'
  },
  {
    id: 71, subject: '线代', chapter: '矩阵', title: '伴随矩阵的秩',
    formula: 'r(A*) = n（当 r(A) = n）\nr(A*) = 1（当 r(A) = n-1）\nr(A*) = 0（当 r(A) < n-1）',
    condition: 'n ≥ 2；由 AA* = |A|E 推出'
  },
  // ---- 向量组 ----
  {
    id: 16, subject: '线代', chapter: '向量组', title: '线性相关定义',
    formula: 'α1, α2, …, αs 线性相关 ⇔ 存在不全为零的 k_i\n使 k1α1 + k2α2 + … + ksαs = 0',
    condition: 's 个 n 维向量'
  },
  {
    id: 17, subject: '线代', chapter: '向量组', title: '秩与相关性',
    formula: '向量组 α1, …, αs 线性无关 ⇔ r(α1, …, αs) = s',
    condition: 'r 为向量组的秩'
  },
  {
    id: 72, subject: '线代', chapter: '向量组', title: '施密特正交化',
    formula: 'β1 = α1\nβ2 = α2 - [α2,β1]/[β1,β1]·β1\nβk = αk - ∑[αk,βi]/[βi,βi]·βi（i < k）',
    condition: '内积 [α,β] = α^T·β；之后单位化得标准正交组'
  },
  {
    id: 73, subject: '线代', chapter: '向量组', title: '极大线性无关组',
    formula: '极大无关组所含向量个数 = 向量组的秩 r\n向量组中任意 r 个线性无关的向量都是极大无关组',
    condition: '求法：行变换化阶梯形，主元所在列对应原向量'
  },
  // ---- 线性方程组 ----
  {
    id: 18, subject: '线代', chapter: '线性方程组', title: '基础解系',
    formula: 'Ax = 0 的基础解系含 n - r(A) 个解向量',
    condition: 'A 为 m×n 矩阵，且 r(A) < n'
  },
  {
    id: 74, subject: '线代', chapter: '线性方程组', title: '非齐次方程组解的结构',
    formula: 'Ax = b 的通解 = 一个特解 x* + 对应齐次通解\nx = x* + k1·ξ1 + … + k_(n-r)·ξ_(n-r)',
    condition: 'ξ1, …, ξ_(n-r) 为 Ax = 0 的基础解系'
  },
  {
    id: 75, subject: '线代', chapter: '线性方程组', title: '有解判定定理',
    formula: 'Ax = b 有解 ⇔ r(A) = r(A, b)\n唯一解 ⇔ r(A) = r(A, b) = n\n无穷多解 ⇔ r(A) = r(A, b) < n',
    condition: 'n 元线性方程组（A 有 n 列）'
  },
  {
    id: 76, subject: '线代', chapter: '线性方程组', title: '齐次方程的非零解',
    formula: 'Ax = 0 有非零解 ⇔ r(A) < n\n方阵情形 ⇔ |A| = 0',
    condition: 'n 为未知数个数；方程个数少于未知数时必有非零解'
  },
  // ---- 特征值 ----
  {
    id: 19, subject: '线代', chapter: '特征值', title: '特征方程',
    formula: '|λE - A| = 0',
    condition: '解得 λ 即 A 的特征值'
  },
  {
    id: 20, subject: '线代', chapter: '特征值', title: '特征值性质',
    formula: 'λ1 + λ2 + … + λn = 迹 tr(A)\nλ1·λ2·…·λn = |A|',
    condition: 'λi 为 A 的全部特征值'
  },
  {
    id: 77, subject: '线代', chapter: '特征值', title: '特征向量的线性无关性',
    formula: 'A 的互不相同特征值对应的特征向量线性无关',
    condition: '同一特征值的无关向量由 (λE - A)x = 0 的基础解系给出'
  },
  {
    id: 78, subject: '线代', chapter: '特征值', title: '相似对角化条件',
    formula: 'A 可相似对角化 ⇔ A 有 n 个线性无关特征向量\n⇔ 每个 k_i 重特征值有 k_i 个线性无关特征向量',
    condition: '特征值互不相同时必可对角化'
  },
  {
    id: 79, subject: '线代', chapter: '特征值', title: '相似矩阵的性质',
    formula: 'A ~ B ⇒ tr(A) = tr(B)，|A| = |B|，特征多项式相同',
    condition: '常用于反求参数：比较迹或行列式'
  },
  {
    id: 80, subject: '线代', chapter: '特征值', title: '实对称矩阵正交对角化',
    formula: '实对称矩阵 A 必存在正交矩阵 Q\n使 Q^T·A·Q = Λ（对角矩阵）',
    condition: '不同特征值的特征向量自动正交，重根需施密特正交化'
  },
  // ---- 二次型 ----
  {
    id: 81, subject: '线代', chapter: '二次型', title: '正定二次型判定',
    formula: 'f = x^T·A·x 正定 ⇔ A 的特征值全 > 0\n⇔ 顺序主子式全 > 0 ⇔ 正惯性指数 = n',
    condition: 'A 必为实对称矩阵'
  },
  // ================= 概率论与数理统计（34 条） =================
  // ---- 随机事件 ----
  {
    id: 21, subject: '概率论', chapter: '随机事件', title: '加法公式',
    formula: 'P(A∪B) = P(A) + P(B) - P(AB)',
    condition: 'A、B 为任意事件；互斥时 P(AB) = 0'
  },
  {
    id: 22, subject: '概率论', chapter: '随机事件', title: '条件概率',
    formula: 'P(B|A) = P(AB)/P(A)',
    condition: 'P(A) > 0'
  },
  {
    id: 23, subject: '概率论', chapter: '随机事件', title: '全概率公式',
    formula: 'P(B) = ∑P(A_i)·P(B|A_i)',
    condition: 'A1, A2, …, An 为完备事件组'
  },
  {
    id: 24, subject: '概率论', chapter: '随机事件', title: '贝叶斯公式',
    formula: 'P(A_j|B) = P(A_j)·P(B|A_j) / ∑P(A_i)·P(B|A_i)',
    condition: 'P(B) > 0，A_i 为完备事件组'
  },
  {
    id: 82, subject: '概率论', chapter: '随机事件', title: '乘法公式',
    formula: 'P(AB) = P(A)·P(B|A) = P(B)·P(A|B)\nP(A1A2…An) = P(A1)·P(A2|A1)···P(An|A1…A_(n-1))',
    condition: '各条件概率的分母均大于 0'
  },
  {
    id: 83, subject: '概率论', chapter: '随机事件', title: '事件的独立性',
    formula: 'A、B 独立 ⇔ P(AB) = P(A)·P(B)\n独立时 P(A|B) = P(A)；A 与 B̄、Ā 与 B 也独立',
    condition: '独立与互斥是不同概念：概率均正的互斥事件必不独立'
  },
  {
    id: 84, subject: '概率论', chapter: '随机事件', title: '减法公式与德摩根律',
    formula: 'P(A - B) = P(A) - P(AB)\nP(A∪B) 的对立事件 = Ā·B̄，即 P(A∪B)‾ = 1 - P(A) - P(B) + P(AB)',
    condition: '文氏图辅助记忆更直观'
  },
  // ---- 一维随机变量 ----
  {
    id: 25, subject: '概率论', chapter: '一维随机变量', title: '分布函数',
    formula: 'F(x) = P(X ≤ x)',
    condition: 'F(x) 单调不减、右连续，F(-∞) = 0，F(+∞) = 1'
  },
  {
    id: 26, subject: '概率论', chapter: '一维随机变量', title: '数学期望',
    formula: 'E(X) = ∑x_i·p_i（离散）\nE(X) = ∫x·f(x)dx（连续）',
    condition: '级数 / 积分绝对收敛'
  },
  {
    id: 27, subject: '概率论', chapter: '一维随机变量', title: '方差计算公式',
    formula: 'D(X) = E(X^2) - [E(X)]^2',
    condition: 'E(X^2) 存在'
  },
  // ---- 常见分布 ----
  {
    id: 85, subject: '概率论', chapter: '常见分布', title: '常见离散分布的期望与方差',
    formula: '0-1 分布：E = p，D = p(1-p)\n二项 B(n, p)：E = np，D = np(1-p)\n泊松 P(λ)：E = λ，D = λ',
    condition: '考场必备数值，直接代入'
  },
  {
    id: 86, subject: '概率论', chapter: '常见分布', title: '泊松定理',
    formula: 'n 很大、p 很小、np = λ 适中时\n二项分布 B(n, p) ≈ 泊松分布 P(np)',
    condition: '一般 n ≥ 20、p ≤ 0.05 时近似效果良好'
  },
  {
    id: 87, subject: '概率论', chapter: '常见分布', title: '均匀分布与指数分布',
    formula: 'U(a, b)：密度 1/(b-a)，E = (a+b)/2，D = (b-a)²/12\nE(λ)：密度 λ·e^(-λx)（x > 0），E = 1/λ，D = 1/λ²',
    condition: '连续型两大常用分布'
  },
  {
    id: 88, subject: '概率论', chapter: '常见分布', title: '指数分布的无记忆性',
    formula: 'P(X > s + t | X > s) = P(X > t)',
    condition: '连续型分布中只有指数分布具有该性质'
  },
  // ---- 多维随机变量 ----
  {
    id: 89, subject: '概率论', chapter: '多维随机变量', title: '二维正态分布',
    formula: '(X, Y) ~ N(μ1, μ2, σ1², σ2², ρ)\n边缘分布均为一维正态；X 与 Y 独立 ⇔ ρ = 0',
    condition: '给定 X = x 时 Y 的条件分布也是正态'
  },
  {
    id: 90, subject: '概率论', chapter: '多维随机变量', title: '条件分布',
    formula: '离散：P(X = x | Y = y) = P(X = x, Y = y)/P(Y = y)\n连续：f(x|y) = f(x, y)/f_Y(y)',
    condition: '分母为边缘分布，且必须大于 0'
  },
  {
    id: 91, subject: '概率论', chapter: '多维随机变量', title: '相互独立性判定',
    formula: 'X、Y 相互独立 ⇔ F(x, y) = F_X(x)·F_Y(y)\n⇔ 联合密度 = 边缘密度的乘积（处处成立）',
    condition: '二维正态分布中独立 ⇔ ρ = 0（特殊结论）'
  },
  {
    id: 92, subject: '概率论', chapter: '多维随机变量', title: '卷积公式',
    formula: 'Z = X + Y 的密度函数\nf_Z(z) = ∫(-∞→+∞) f(x, z - x) dx',
    condition: '要求 X、Y 相互独立'
  },
  // ---- 数字特征 ----
  {
    id: 28, subject: '概率论', chapter: '数字特征', title: '期望与方差的性质',
    formula: 'E(aX + b) = a·E(X) + b\nD(aX + b) = a^2·D(X)',
    condition: 'a、b 为常数'
  },
  {
    id: 29, subject: '概率论', chapter: '数字特征', title: '协方差公式',
    formula: 'Cov(X, Y) = E(XY) - E(X)·E(Y)',
    condition: 'E(XY) 存在'
  },
  {
    id: 93, subject: '概率论', chapter: '数字特征', title: '相关系数',
    formula: 'ρ_XY = Cov(X, Y) / (√D(X)·√D(Y))，|ρ| ≤ 1\n|ρ| = 1 ⇔ 存在常数 a ≠ 0 使 P(Y = aX + b) = 1',
    condition: 'ρ = 0 只说明无线性关系，不代表独立'
  },
  {
    id: 94, subject: '概率论', chapter: '数字特征', title: '协方差的性质',
    formula: 'Cov(aX + b, cY + d) = ac·Cov(X, Y)\nCov(X, X) = D(X)\nCov(X, Y) = E(XY) - E(X)·E(Y)',
    condition: '双线性展开是化简的常用手段'
  },
  {
    id: 95, subject: '概率论', chapter: '数字特征', title: '独立与协方差',
    formula: 'X、Y 独立 ⇒ Cov(X, Y) = 0\n反之不成立（Cov = 0 推不出独立）',
    condition: '反例：非线性相关但协方差为零的分布'
  },
  {
    id: 96, subject: '概率论', chapter: '数字特征', title: '切比雪夫不等式',
    formula: 'P(|X - E(X)| ≥ ε) ≤ D(X)/ε²\n等价：P(|X - E(X)| < ε) ≥ 1 - D(X)/ε²',
    condition: '只知道期望与方差时的概率估计工具'
  },
  // ---- 大数定律 ----
  {
    id: 30, subject: '概率论', chapter: '大数定律', title: '独立同分布中心极限定理',
    formula: 'lim(n→∞) P[(∑X_i - nμ)/(√n·σ) ≤ x] = Φ(x)',
    condition: 'X_i 独立同分布且方差存在'
  },
  {
    id: 97, subject: '概率论', chapter: '大数定律', title: '切比雪夫与辛钦大数定律',
    formula: '切比雪夫：独立 + 方差一致有界 ⇒ X̄ →P E(X)\n辛钦：独立同分布 + 期望存在 ⇒ X̄ →P μ',
    condition: '→P 表示依概率收敛'
  },
  {
    id: 98, subject: '概率论', chapter: '大数定律', title: '伯努利大数定律',
    formula: 'n 重伯努利试验中，频率 n_A/n →P p',
    condition: '「频率稳定于概率」的理论依据'
  },
  {
    id: 99, subject: '概率论', chapter: '大数定律', title: '棣莫弗-拉普拉斯定理',
    formula: '(∑X_i - np)/√(np(1-p)) 近似 N(0, 1)\n其中 X_i ~ B(1, p) 独立同分布',
    condition: '二项分布的正态近似；p 不接近 0 或 1 时效果好'
  },
  // ---- 数理统计 ----
  {
    id: 100, subject: '概率论', chapter: '数理统计', title: 'χ² 分布',
    formula: '(n-1)·S²/σ² ~ χ²(n-1)\n即 ∑(X_i - X̄)²/σ² ~ χ²(n-1)',
    condition: 'X_i 为正态总体 N(μ, σ²) 的样本；数一数三内容'
  },
  {
    id: 101, subject: '概率论', chapter: '数理统计', title: '正态总体的抽样分布',
    formula: 'X̄ ~ N(μ, σ²/n)\n√n·(X̄ - μ)/σ ~ N(0, 1)\n√n·(X̄ - μ)/S ~ t(n - 1)',
    condition: 'S 为样本标准差；t 分布自由度为 n - 1'
  },
  {
    id: 102, subject: '概率论', chapter: '数理统计', title: '样本方差的期望',
    formula: 'E(S²) = σ²，即 S² 是 σ² 的无偏估计\n但 E(S) ≠ σ（S 是有偏的）',
    condition: 'S² = 1/(n-1)·∑(X_i - X̄)²'
  },
  {
    id: 103, subject: '概率论', chapter: '数理统计', title: '矩估计与最大似然估计',
    formula: '矩估计：令样本矩 = 相应总体矩，解出 θ\n最大似然：L(θ) = ∏f(x_i; θ)，求使 L(θ) 最大的 θ',
    condition: '先写似然函数，取对数后求导（数一数三内容）'
  },
  {
    id: 104, subject: '概率论', chapter: '数理统计', title: '正态均值的置信区间',
    formula: 'σ² 已知：X̄ ± z_(α/2)·σ/√n\nσ² 未知：X̄ ± t_(α/2)(n-1)·S/√n',
    condition: '置信水平 1 - α'
  },
  {
    id: 105, subject: '概率论', chapter: '数理统计', title: '假设检验的两类错误',
    formula: '第一类错误（弃真）：H0 为真却拒绝 H0，概率 ≤ α\n第二类错误（取伪）：H0 为假却接受 H0，概率为 β',
    condition: '样本量固定时 α 与 β 此消彼长'
  }
];
