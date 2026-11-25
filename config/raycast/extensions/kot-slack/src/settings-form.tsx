import { Action, ActionPanel, Form, showToast, Toast, useNavigation } from "@raycast/api";
import { Config, loadConfig, saveConfig, Status } from "./config";

interface Values {
  clockIn: string;
  takeABreak: string;
  breakIsOver: string;
  clockOut: string;
  workingEmoji: string;
  workingText: string;
  breakEmoji: string;
  breakText: string;
  offEmoji: string;
  offText: string;
  offClear: boolean;
}

const toLines = (value: string) =>
  value
    .split("\n")
    .map((v) => v.trim())
    .filter((v) => v.length > 0);

// 絵文字とテキストが両方空なら、そのときはステータスを変更しない
const toStatus = (emoji: string, text: string): Status | undefined =>
  emoji.trim() || text.trim() ? { emoji: emoji.trim(), text: text.trim() } : undefined;

function readCurrent(): Config | undefined {
  try {
    return loadConfig();
  } catch {
    return undefined;
  }
}

// 入力欄は defaultValue だけを渡す。value で制御すると日本語の変換中に入力が確定されてしまう
export function SettingsForm({ onSave }: { onSave?: () => void }) {
  const { pop } = useNavigation();
  const current = readCurrent();
  const off = current?.status.off;

  async function submit(values: Values) {
    try {
      saveConfig({
        messages: {
          clockIn: toLines(values.clockIn),
          takeABreak: toLines(values.takeABreak),
          breakIsOver: toLines(values.breakIsOver),
          clockOut: toLines(values.clockOut),
        },
        status: {
          working: toStatus(values.workingEmoji, values.workingText),
          break: toStatus(values.breakEmoji, values.breakText),
          off: toStatus(values.offEmoji, values.offText) ?? (values.offClear ? { emoji: "", text: "" } : undefined),
        },
      });
    } catch (e) {
      await showToast({
        style: Toast.Style.Failure,
        title: "保存できませんでした",
        message: e instanceof Error ? e.message : String(e),
      });
      return;
    }
    await showToast({ style: Toast.Style.Success, title: "保存しました" });
    onSave?.();
    pop();
  }

  return (
    <Form
      actions={
        <ActionPanel>
          <Action.SubmitForm title="保存する" onSubmit={submit} />
        </ActionPanel>
      }
    >
      <Form.Description text="メッセージは1行に1つ書きます。勤務場所ごとに行を分けると、打刻のときに選べます。空欄の種類は投稿しません。" />
      <Form.TextArea
        id="clockIn"
        title="出勤メッセージ"
        placeholder={"リモートワーク開始します。\n大阪オフィス出社しました。"}
        defaultValue={current?.messages.clockIn.join("\n") ?? ""}
      />
      <Form.TextArea
        id="takeABreak"
        title="休憩開始メッセージ"
        defaultValue={current?.messages.takeABreak.join("\n") ?? ""}
      />
      <Form.TextArea
        id="breakIsOver"
        title="再開メッセージ"
        defaultValue={current?.messages.breakIsOver.join("\n") ?? ""}
      />
      <Form.TextArea
        id="clockOut"
        title="退勤メッセージ"
        defaultValue={current?.messages.clockOut.join("\n") ?? ""}
      />
      <Form.Separator />
      <Form.Description text="ステータスは、拡張機能の設定で「打刻に合わせてステータスを変更する」を有効にしたときだけ使います。絵文字とテキストが両方空欄なら、そのときは変更しません。" />
      <Form.TextField
        id="workingEmoji"
        title="勤務中の絵文字"
        placeholder=":office:"
        defaultValue={current?.status.working?.emoji ?? ""}
      />
      <Form.TextField
        id="workingText"
        title="勤務中のテキスト"
        placeholder="仕事中"
        defaultValue={current?.status.working?.text ?? ""}
      />
      <Form.TextField
        id="breakEmoji"
        title="休憩中の絵文字"
        placeholder=":coffee:"
        defaultValue={current?.status.break?.emoji ?? ""}
      />
      <Form.TextField
        id="breakText"
        title="休憩中のテキスト"
        placeholder="休憩中"
        defaultValue={current?.status.break?.text ?? ""}
      />
      <Form.TextField
        id="offEmoji"
        title="退勤後の絵文字"
        placeholder=":house:"
        defaultValue={off?.emoji ?? ""}
      />
      <Form.TextField
        id="offText"
        title="退勤後のテキスト"
        placeholder="プライベートタイム"
        defaultValue={off?.text ?? ""}
      />
      <Form.Checkbox
        id="offClear"
        label="退勤後の絵文字とテキストが空欄なら、退勤時にステータスを消す"
        defaultValue={off !== undefined && !off.emoji && !off.text}
      />
    </Form>
  );
}
