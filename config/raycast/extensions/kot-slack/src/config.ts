import { existsSync, mkdirSync, readFileSync, writeFileSync } from "node:fs";
import { homedir } from "node:os";
import { dirname, join } from "node:path";

export type Kind = "clockIn" | "takeABreak" | "breakIsOver" | "clockOut";

export interface Status {
  emoji: string;
  text: string;
}

export interface Config {
  messages: Record<Kind, string[]>;
  // working は出勤・再開、break は休憩開始、off は退勤のときに設定する。未設定の項目は変更しない
  status: { working?: Status; break?: Status; off?: Status };
}

// 拡張機能の設定欄は1行しか書けず日本語入力も崩れるため、メッセージとステータスはファイルに持ち、フォームから編集する
export const CONFIG_PATH = join(homedir(), ".config", "kot-slack", "config.json");

export function saveConfig(config: Config): void {
  mkdirSync(dirname(CONFIG_PATH), { recursive: true });
  writeFileSync(CONFIG_PATH, JSON.stringify(config, null, 2) + "\n");
}

const toMessages = (value: unknown): string[] =>
  (Array.isArray(value) ? value : typeof value === "string" ? [value] : [])
    .map((v) => String(v).trim())
    .filter((v) => v.length > 0);

const toStatus = (value: unknown): Status | undefined => {
  if (typeof value !== "object" || value === null) return undefined;
  const { emoji, text } = value as Partial<Status>;
  return { emoji: String(emoji ?? ""), text: String(text ?? "") };
};

// ファイルがなければ undefined を返し、JSON として読めなければ例外を投げる
export function loadConfig(): Config | undefined {
  if (!existsSync(CONFIG_PATH)) return undefined;
  const raw = JSON.parse(readFileSync(CONFIG_PATH, "utf8"));
  const messages = raw?.messages ?? {};
  const status = raw?.status ?? {};
  return {
    messages: {
      clockIn: toMessages(messages.clockIn),
      takeABreak: toMessages(messages.takeABreak),
      breakIsOver: toMessages(messages.breakIsOver),
      clockOut: toMessages(messages.clockOut),
    },
    status: { working: toStatus(status.working), break: toStatus(status.break), off: toStatus(status.off) },
  };
}
