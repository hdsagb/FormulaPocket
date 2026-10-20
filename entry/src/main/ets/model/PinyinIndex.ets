/**
 * 标题拼音索引：由 Formula.ets 的 105 条标题预生成（脚本产出，勿手工编辑）。
 * py = 全拼小写连写；sx = 拼音首字母串（英文/数字原样保留首字符）。
 * 用于支持全中文 / 全拼音 / 拼音首字母 / 中英混合搜索。
 */

export interface PinyinEntry {
  id: number;
  py: string;  // 全拼连写，如 tailgongshi
  sx: string;  // 首字母串，如 tlgs
}

export const PINYIN_INDEX: PinyinEntry[] = [
  { id: 1, py: 'lianggezhongyaojixian', sx: 'lgzyjx' }, // 两个重要极限
  { id: 2, py: 'luobidafaze', sx: 'lbdfz' }, // 洛必达法则
  { id: 3, py: 'dengjiawuqiongxiaotihuan', sx: 'djwqxth' }, // 等价无穷小替换
  { id: 31, py: 'jixiansizeyunsuanfaze', sx: 'jxszysfz' }, // 极限四则运算法则
  { id: 32, py: 'wuqiongxiaodebijiao', sx: 'wqxdbj' }, // 无穷小的比较
  { id: 33, py: 'jiabizhunze', sx: 'jbzz' }, // 夹逼准则
  { id: 34, py: 'dandiaoyoujiezhunze', sx: 'ddyjzz' }, // 单调有界准则
  { id: 35, py: 'taileigongshi', sx: 'tlgs' }, // 泰勒公式
  { id: 36, py: 'changyongmaikelaolinzhankai', sx: 'cymkllzk' }, // 常用麦克劳林展开
  { id: 37, py: 'xingjixian', sx: '1xjx' }, // 1^∞ 型极限
  { id: 38, py: 'jianjinxian', sx: 'jjx' }, // 渐近线
  { id: 4, py: 'daoshudedingyi', sx: 'dsddy' }, // 导数的定义
  { id: 5, py: 'sizeqiudaofaze', sx: 'szqdfz' }, // 四则求导法则
  { id: 6, py: 'lianshifaze', sx: 'lsfz' }, // 链式法则
  { id: 7, py: 'lagelangrizhongzhidingli', sx: 'lglrzzdl' }, // 拉格朗日中值定理
  { id: 39, py: 'yinhanshuqiudao', sx: 'yhsqd' }, // 隐函数求导
  { id: 40, py: 'canshufangchengqiudao', sx: 'csfcqd' }, // 参数方程求导
  { id: 41, py: 'laibunicigongshi', sx: 'lbncgs' }, // 莱布尼茨公式
  { id: 42, py: 'changjianhanshugaojiedaoshu', sx: 'cjhsgjds' }, // 常见函数高阶导数
  { id: 43, py: 'kexizhongzhidingli', sx: 'kxzzdl' }, // 柯西中值定理
  { id: 44, py: 'jizhidierchongfentiaojian', sx: 'jzdecftj' }, // 极值第二充分条件
  { id: 8, py: 'niudunlaibunicigongshi', sx: 'nd-lbncgs' }, // 牛顿-莱布尼茨公式
  { id: 9, py: 'fenbujifenfa', sx: 'fbjff' }, // 分部积分法
  { id: 45, py: 'jibenjifenbiao', sx: 'jbjfb' }, // 基本积分表
  { id: 46, py: 'huanyuanjifenfa', sx: 'hyjff' }, // 换元积分法
  { id: 47, py: 'dingjifenjiouduichenxing', sx: 'djfjodcx' }, // 定积分奇偶对称性
  { id: 48, py: 'bianxianjifenqiudao', sx: 'bxjfqd' }, // 变限积分求导
  { id: 49, py: 'jifenzhongzhidingli', sx: 'jfzzdl' }, // 积分中值定理
  { id: 50, py: 'xuanzhuantitiji', sx: 'xzttj' }, // 旋转体体积
  { id: 51, py: 'pingmianquxianhuzhang', sx: 'pmqxhz' }, // 平面曲线弧长
  { id: 52, py: 'piandaoshuyuquanweifen', sx: 'pdsyqwf' }, // 偏导数与全微分
  { id: 53, py: 'duoyuanfuhelianshifaze', sx: 'dyfhlsfz' }, // 多元复合链式法则
  { id: 54, py: 'duoyuanjizhichongfentiaojian', sx: 'dyjzcftj' }, // 多元极值充分条件
  { id: 55, py: 'lagelangrichengshufa', sx: 'lglrcsf' }, // 拉格朗日乘数法
  { id: 56, py: 'erchongjifenjisuan', sx: 'ecjfjs' }, // 二重积分计算
  { id: 57, py: 'gelingongshi', sx: 'glgs' }, // 格林公式
  { id: 58, py: 'gaosigongshi', sx: 'gsgs' }, // 高斯公式
  { id: 59, py: 'yijiexianxingfangchengtongjie', sx: 'yjxxfctj' }, // 一阶线性方程通解
  { id: 60, py: 'erjiechangxishuxianxingfangcheng', sx: 'ejcxsxxfc' }, // 二阶常系数线性方程
  { id: 10, py: 'dengbijishu', sx: 'dbjs' }, // 等比级数
  { id: 61, py: 'jishuyutiaohejishu', sx: 'pjsythjs' }, // p 级数与调和级数
  { id: 62, py: 'bizhipanbiefa', sx: 'bzpbf' }, // 比值判别法
  { id: 63, py: 'laibunicipanbiefa', sx: 'lbncpbf' }, // 莱布尼茨判别法
  { id: 64, py: 'jueduishoulianyutiaojianshoulian', sx: 'jdslytjsl' }, // 绝对收敛与条件收敛
  { id: 65, py: 'mijishushoulianbanjing', sx: 'mjsslbj' }, // 幂级数收敛半径
  { id: 11, py: 'hanglieshichengfaxingzhi', sx: 'hlscfxz' }, // 行列式乘法性质
  { id: 12, py: 'kelamofaze', sx: 'klmfz' }, // 克拉默法则
  { id: 66, py: 'anxingliezhankaidingli', sx: 'axlzkdl' }, // 按行（列）展开定理
  { id: 67, py: 'fandemengdexinglieshi', sx: 'fdmdxls' }, // 范德蒙德行列式
  { id: 68, py: 'hanglieshijibenxingzhi', sx: 'hlsjbxz' }, // 行列式基本性质
  { id: 13, py: 'nijuzhengongshi', sx: 'njzgs' }, // 逆矩阵公式
  { id: 14, py: 'bansuijuzhenxingzhi', sx: 'bsjzxz' }, // 伴随矩阵性质
  { id: 15, py: 'zhuanzhiyunsuanlv', sx: 'zzysl' }, // 转置运算律
  { id: 69, py: 'kenidechongyaotiaojian', sx: 'kndcytj' }, // 可逆的充要条件
  { id: 70, py: 'zhidejibenbudengshi', sx: 'zdjbbds' }, // 秩的基本不等式
  { id: 71, py: 'bansuijuzhendezhi', sx: 'bsjzdz' }, // 伴随矩阵的秩
  { id: 16, py: 'xianxingxiangguandingyi', sx: 'xxxgdy' }, // 线性相关定义
  { id: 17, py: 'zhiyuxiangguanxing', sx: 'zyxgx' }, // 秩与相关性
  { id: 72, py: 'shimitezhengjiaohua', sx: 'smtzjh' }, // 施密特正交化
  { id: 73, py: 'jidaxianxingwuguanzu', sx: 'jdxxwgz' }, // 极大线性无关组
  { id: 18, py: 'jichujiexi', sx: 'jcjx' }, // 基础解系
  { id: 74, py: 'feiqicifangchengzujiedejiegou', sx: 'fqcfczjdjg' }, // 非齐次方程组解的结构
  { id: 75, py: 'youjiepandingdingli', sx: 'yjpddl' }, // 有解判定定理
  { id: 76, py: 'qicifangchengdefeilingjie', sx: 'qcfcdflj' }, // 齐次方程的非零解
  { id: 19, py: 'tezhengfangcheng', sx: 'tzfc' }, // 特征方程
  { id: 20, py: 'tezhengzhixingzhi', sx: 'tzzxz' }, // 特征值性质
  { id: 77, py: 'tezhengxiangliangdexianxingwuguanxing', sx: 'tzxldxxwgx' }, // 特征向量的线性无关性
  { id: 78, py: 'xiangsiduijiaohuatiaojian', sx: 'xsdjhtj' }, // 相似对角化条件
  { id: 79, py: 'xiangsijuzhendexingzhi', sx: 'xsjzdxz' }, // 相似矩阵的性质
  { id: 80, py: 'shiduichenjuzhenzhengjiaoduijiaohua', sx: 'sdcjzzjdjh' }, // 实对称矩阵正交对角化
  { id: 81, py: 'zhengdingercixingpanding', sx: 'zdecxpd' }, // 正定二次型判定
  { id: 21, py: 'jiafagongshi', sx: 'jfgs' }, // 加法公式
  { id: 22, py: 'tiaojiangailv', sx: 'tjgl' }, // 条件概率
  { id: 23, py: 'quangailvgongshi', sx: 'qglgs' }, // 全概率公式
  { id: 24, py: 'beiyesigongshi', sx: 'bysgs' }, // 贝叶斯公式
  { id: 82, py: 'chengfagongshi', sx: 'cfgs' }, // 乘法公式
  { id: 83, py: 'shijiandedulixing', sx: 'sjddlx' }, // 事件的独立性
  { id: 84, py: 'jianfagongshiyudemogenlv', sx: 'jfgsydmgl' }, // 减法公式与德摩根律
  { id: 25, py: 'fenbuhanshu', sx: 'fbhs' }, // 分布函数
  { id: 26, py: 'shuxueqiwang', sx: 'sxqw' }, // 数学期望
  { id: 27, py: 'fangchajisuangongshi', sx: 'fcjsgs' }, // 方差计算公式
  { id: 85, py: 'changjianlisanfenbudeqiwangyufangcha', sx: 'cjlsfbdqwyfc' }, // 常见离散分布的期望与方差
  { id: 86, py: 'posongdingli', sx: 'psdl' }, // 泊松定理
  { id: 87, py: 'junyunfenbuyuzhishufenbu', sx: 'jyfbyzsfb' }, // 均匀分布与指数分布
  { id: 88, py: 'zhishufenbudewujiyixing', sx: 'zsfbdwjyx' }, // 指数分布的无记忆性
  { id: 89, py: 'erweizhengtaifenbu', sx: 'ewztfb' }, // 二维正态分布
  { id: 90, py: 'tiaojianfenbu', sx: 'tjfb' }, // 条件分布
  { id: 91, py: 'xianghudulixingpanding', sx: 'xhdlxpd' }, // 相互独立性判定
  { id: 92, py: 'juanjigongshi', sx: 'jjgs' }, // 卷积公式
  { id: 28, py: 'qiwangyufangchadexingzhi', sx: 'qwyfcdxz' }, // 期望与方差的性质
  { id: 29, py: 'xiefangchagongshi', sx: 'xfcgs' }, // 协方差公式
  { id: 93, py: 'xiangguanxishu', sx: 'xgxs' }, // 相关系数
  { id: 94, py: 'xiefangchadexingzhi', sx: 'xfcdxz' }, // 协方差的性质
  { id: 95, py: 'duliyuxiefangcha', sx: 'dlyxfc' }, // 独立与协方差
  { id: 96, py: 'qiebixuefubudengshi', sx: 'qbxfbds' }, // 切比雪夫不等式
  { id: 30, py: 'dulitongfenbuzhongxinjixiandingli', sx: 'dltfbzxjxdl' }, // 独立同分布中心极限定理
  { id: 97, py: 'qiebixuefuyuxinqindashudinglv', sx: 'qbxfyxqdsdl' }, // 切比雪夫与辛钦大数定律
  { id: 98, py: 'bonulidashudinglv', sx: 'bnldsdl' }, // 伯努利大数定律
  { id: 99, py: 'dimofulapulasidingli', sx: 'dmf-lplsdl' }, // 棣莫弗-拉普拉斯定理
  { id: 100, py: 'fenbu', sx: 'fb' }, // χ² 分布
  { id: 101, py: 'zhengtaizongtidechouyangfenbu', sx: 'ztztdcyfb' }, // 正态总体的抽样分布
  { id: 102, py: 'yangbenfangchadeqiwang', sx: 'ybfcdqw' }, // 样本方差的期望
  { id: 103, py: 'jugujiyuzuidashiranguji', sx: 'jgjyzdsrgj' }, // 矩估计与最大似然估计
  { id: 104, py: 'zhengtaijunzhidezhixinqujian', sx: 'ztjzdzxqj' }, // 正态均值的置信区间
  { id: 105, py: 'jiashejianyandeliangleicuowu', sx: 'jsjydllcw' }, // 假设检验的两类错误
];

/** 构建 id -> 拼音条目 的快速查询表 */
export function buildPinyinMap(): Map<number, PinyinEntry> {
  const m: Map<number, PinyinEntry> = new Map();
  for (const e of PINYIN_INDEX) {
    m.set(e.id, e);
  }
  return m;
}
