/**
 * 主题模式：
 * - 颜色全部走资源（app.color.*），浅色在 base、深色在 dark，系统按当前颜色模式自动取用
 * - 本文件只负责「让应用进入哪个颜色模式」，不参与具体配色
 */
import { common, ConfigurationConstant } from '@kit.AbilityKit';
import { preferences } from '@kit.ArkData';

export const THEME_SYSTEM: string = 'system';
export const THEME_LIGHT: string = 'light';
export const THEME_DARK: string = 'dark';

/** 设置面板中的展示顺序 */
export const THEME_OPTIONS: string[] = [THEME_SYSTEM, THEME_LIGHT, THEME_DARK];
export const THEME_LABELS: string[] = ['跟随系统', '浅色', '深色'];

/** 非法值回落为「跟随系统」，避免旧数据导致异常 */
export function normalizeThemeMode(raw: string): string {
  return THEME_OPTIONS.includes(raw) ? raw : THEME_SYSTEM;
}

const PREF_NAME: string = 'formula_settings';
const PREF_THEME_KEY: string = 'themeMode';

/**
 * 主题另存一份到 preferences：
 * PersistentStorage 只能在 UI 侧读取，启动时窗口加载前拿不到；
 * preferences 支持同步读取，可在 loadContent 之前就切好颜色模式，避免冷启动闪一帧浅色。
 */
export function saveThemeToPrefs(context: common.Context | undefined, mode: string): void {
  if (context === undefined) {
    return;
  }
  try {
    const store: preferences.Preferences = preferences.getPreferencesSync(context, { name: PREF_NAME });
    store.putSync(PREF_THEME_KEY, normalizeThemeMode(mode));
    store.flush().catch(() => {
      // 落盘失败时下次启动退回系统默认，不影响本次会话
    });
  } catch (err) {
    // preferences 不可用时忽略，仅影响冷启动时机
  }
}

export function loadThemeFromPrefs(context: common.Context | undefined): string {
  if (context === undefined) {
    return THEME_SYSTEM;
  }
  try {
    const store: preferences.Preferences = preferences.getPreferencesSync(context, { name: PREF_NAME });
    return normalizeThemeMode(store.getSync(PREF_THEME_KEY, THEME_SYSTEM) as string);
  } catch (err) {
    return THEME_SYSTEM;
  }
}

/** 应用颜色模式（立即生效，资源会按新模式重新解析） */
export function applyThemeMode(context: common.Context | undefined, mode: string): void {
  if (context === undefined) {
    return;
  }
  const normalized: string = normalizeThemeMode(mode);
  let colorMode: ConfigurationConstant.ColorMode = ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET;
  if (normalized === THEME_LIGHT) {
    colorMode = ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT;
  } else if (normalized === THEME_DARK) {
    colorMode = ConfigurationConstant.ColorMode.COLOR_MODE_DARK;
  }
  try {
    context.getApplicationContext().setColorMode(colorMode);
  } catch (err) {
    // 颜色模式设置失败时保持系统默认
  }
}
