import {
  Action,
  ActionPanel,
  getPreferenceValues,
  Icon,
  List,
  open,
  openExtensionPreferences,
  PopToRootType,
  showHUD,
  showToast,
  Toast,
} from "@raycast/api";
import { useLocalStorage } from "@raycast/utils";
import { useState } from "react";
import { Config, Kind, loadConfig, Status } from "./config";
import { SettingsForm } from "./settings-form";
import { postMessage, setStatus } from "./slack";

interface Prefs {
  slackToken: string;
  slackChannel: string;
  statusEnabled: boolean;
  statusToken?: string;
  openRecorder: boolean;
  recorderUrl?: string;
}

interface Last {
  kind: Kind;
  date: string;
}

const LABELS: Record<Kind, { title: string; icon: Icon }> = {
  clockIn: { title: "出勤", icon: Icon.Play },
  takeABreak: { title: "休憩開始", icon: Icon.Pause },
  breakIsOver: { title: "再開", icon: Icon.Forward },
  clockOut: { title: "退勤", icon: Icon.Stop },
};

// 直前の打刻から、次に選びそうなものを上に並べる
const ORDER: Record<Kind | "none", Kind[]> = {
  none: ["clockIn", "takeABreak", "breakIsOver", "clockOut"],
  clockIn: ["takeABreak", "clockOut", "breakIsOver", "clockIn"],
  breakIsOver: ["takeABreak", "clockOut", "breakIsOver", "clockIn"],
  takeABreak: ["breakIsOver", "clockOut", "takeABreak", "clockIn"],
  clockOut: ["clockIn", "takeABreak", "breakIsOver", "clockOut"],
};

const splitBySpace = (value: string | undefined) => (value ?? "").split(/\s+/).filter((v) => v.length > 0);

const today = () => new Date().toLocaleDateString("sv-SE");

function statusFor(kind: Kind, config: Config, prefs: Prefs): Status | undefined {
  if (!prefs.statusEnabled) return undefined;
  if (kind === "clockOut") return config.status.off;
  if (kind === "takeABreak") return config.status.break;
  return config.status.working;
}

// 一覧に出すメッセージ。メッセージがなくてもステータスを変えられるなら、ステータスだけ変える項目（空文字）を出す
function messagesFor(kind: Kind, config: Config, prefs: Prefs): string[] {
  const messages = config.messages[kind];
  if (messages.length > 0 || !statusFor(kind, config, prefs)) return messages;
  // 休憩を使わない人の一覧に休憩の項目を出さない
  if ((kind === "takeABreak" || kind === "breakIsOver") && !config.status.break) return [];
  return [""];
}

async function send(message: string, status: Status | undefined, prefs: Prefs): Promise<void> {
  const requests: Promise<void>[] = [];

  if (message) {
    const tokens = splitBySpace(prefs.slackToken);
    splitBySpace(prefs.slackChannel).forEach((channel, i) => {
      requests.push(postMessage(tokens[i] ?? tokens[0], channel, message));
    });
  }
  if (status) {
    for (const token of splitBySpace(prefs.statusToken || prefs.slackToken)) {
      requests.push(setStatus(token, status.emoji, status.text));
    }
  }

  const failed = (await Promise.allSettled(requests)).filter((r) => r.status === "rejected");
  if (failed.length > 0) throw new Error(failed.map((r) => String(r.reason?.message ?? r.reason)).join(", "));
}

function readConfig(): { config?: Config; error?: string } {
  try {
    return { config: loadConfig() };
  } catch (error) {
    return { error: error instanceof Error ? error.message : String(error) };
  }
}

export default function Command() {
  const prefs = getPreferenceValues<Prefs>();
  const [{ config, error }, setLoaded] = useState(readConfig);
  const { value: last, setValue: setLast, isLoading } = useLocalStorage<Last>("last");
  const lastKind = last?.date === today() ? last.kind : "none";

  const configActions = (
    <>
      <Action.Push
        title="メッセージを設定する"
        icon={Icon.Pencil}
        shortcut={{ modifiers: ["cmd"], key: "e" }}
        target={<SettingsForm onSave={() => setLoaded(readConfig())} />}
      />
      <Action title="トークンなどの設定を開く" icon={Icon.Gear} onAction={openExtensionPreferences} />
    </>
  );

  async function punch(kind: Kind, message: string) {
    if (!config) return;
    const toast = await showToast({ style: Toast.Style.Animated, title: "Slack に送信しています" });
    try {
      await send(message, statusFor(kind, config, prefs), prefs);
    } catch (e) {
      toast.style = Toast.Style.Failure;
      toast.title = "Slack への送信に失敗しました";
      toast.message = e instanceof Error ? e.message : String(e);
      return;
    }
    // 送信中のトーストは自動では消えないので、結果を HUD で出す前に消す
    await toast.hide();
    await setLast({ kind, date: today() });
    if (prefs.openRecorder && prefs.recorderUrl) await open(prefs.recorderUrl);
    await showHUD(message ? `投稿しました: ${message}` : `ステータスを変更しました（${LABELS[kind].title}）`, {
      clearRootSearch: true,
      popToRootType: PopToRootType.Immediate,
    });
  }

  const sections = config ? ORDER[lastKind].map((kind) => ({ kind, messages: messagesFor(kind, config, prefs) })) : [];
  const isEmpty = sections.every((s) => s.messages.length === 0);

  return (
    <List isLoading={isLoading} searchBarPlaceholder="打刻の種類やメッセージで絞り込む">
      {isEmpty && (
        <List.EmptyView
          icon={error ? Icon.Warning : Icon.Pencil}
          title={error ? "設定ファイルを読めませんでした" : "メッセージが設定されていません"}
          description={error ?? "Enter を押して、出勤メッセージなどを入力してください"}
          actions={<ActionPanel>{configActions}</ActionPanel>}
        />
      )}
      {sections.map(({ kind, messages }) => (
        <List.Section key={kind} title={LABELS[kind].title}>
          {messages.map((message) => (
            <List.Item
              key={message}
              icon={LABELS[kind].icon}
              title={message || "ステータスだけ変更する"}
              keywords={[LABELS[kind].title]}
              accessories={lastKind === kind ? [{ tag: "前回" }] : []}
              actions={
                <ActionPanel>
                  <Action
                    title={message ? "Slack に投稿する" : "ステータスを変更する"}
                    icon={Icon.Message}
                    onAction={() => punch(kind, message)}
                  />
                  {prefs.recorderUrl && <Action.OpenInBrowser title="Myレコーダーだけ開く" url={prefs.recorderUrl} />}
                  {configActions}
                </ActionPanel>
              }
            />
          ))}
        </List.Section>
      ))}
    </List>
  );
}
