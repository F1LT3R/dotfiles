import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { Type } from "typebox";
import { execSync } from "node:child_process";

const NOTIFY_URL = process.env.AGENT_NOTIFY_URL ?? "http://localhost:8881";

function notify(args: Record<string, unknown>) {
  const params = new URLSearchParams({ type: String(args.type), message: String(args.message) });
  if (args.workspaceDir) params.set("workspaceDir", String(args.workspaceDir));
  if (args.agentRole) params.set("agentRole", String(args.agentRole));
  if (args.agentNumber) params.set("agentNumber", String(args.agentNumber));
  if (args.voice) params.set("voice", String(args.voice));
  if (args.model) params.set("model", String(args.model));
  if (args.to) params.set("to", String(args.to));
  if (args.response_to) params.set("response_to", String(args.response_to));

  const output = execSync(`curl -s "${NOTIFY_URL}/notify/agent?${params}"`, { encoding: "utf-8" });
  return JSON.parse(output);
}

function getMessages(args: Record<string, unknown>) {
  const params = new URLSearchParams({ since_id: String(args.since_id ?? 0) });
  if (args.limit) params.set("limit", String(args.limit));
  if (args.type) params.set("type", String(args.type));
  if (args.to) params.set("to", String(args.to));
  if (args.project) params.set("project", String(args.project));
  if (args.source) params.set("source", String(args.source));
  if (args.agentRole) params.set("agentRole", String(args.agentRole));
  if (args.agentNumber) params.set("agentNumber", String(args.agentNumber));
  if (args.model) params.set("model", String(args.model));
  if (args.voice) params.set("voice", String(args.voice));
  if (args.app) params.set("app", String(args.app));
  if (args.response_to) params.set("response_to", String(args.response_to));

  const output = execSync(`curl -s "${NOTIFY_URL}/messages?${params}"`, { encoding: "utf-8" });
  return JSON.parse(output);
}

function checkMessageStatus(args: Record<string, unknown>) {
  const params = new URLSearchParams();
  if (args.since_id !== undefined) params.set("since_id", String(args.since_id));
  const output = execSync(`curl -s "${NOTIFY_URL}/messages/status?${params}"`, { encoding: "utf-8" });
  return JSON.parse(output);
}

function checkResponses(args: Record<string, unknown>, method: string) {
  const output = execSync(`curl -s "${NOTIFY_URL}/responses/${method}/for/id/${args.id}"`, { encoding: "utf-8" });
  return JSON.parse(output);
}

export default function (pi: ExtensionAPI) {
  pi.registerTool({
    name: "notify",
    label: "Notify",
    description: "Send an audio notification with TTS to alert the user",
    parameters: Type.Object({
      type: Type.String({ description: "Notification type: question, permission, done, error, status, waiting, review, message" }),
      message: Type.String({ description: "Message to vocalize via TTS" }),
      model: Type.Optional(Type.String({ description: "Model identifier, e.g. 'claude-opus-4-6'" })),
      workspaceDir: Type.Optional(Type.String({ description: "Project path for context" })),
      agentRole: Type.Optional(Type.String({ description: "Agent role name (e.g. 'Coder', 'Reviewer')" })),
      agentNumber: Type.Optional(Type.Number({ description: "Agent number" })),
      voice: Type.Optional(Type.String({ description: "Override TTS voice" })),
      to: Type.Optional(Type.String({ description: "Agent role or name this message is directed to" })),
      response_to: Type.Optional(Type.Number({ description: "Message ID this is a reply to" })),
    }),
    async execute(_toolCallId, params) {
      const result = notify(params);
      return {
        content: [{
          type: "text",
          text: `Notification sent (id: ${result.id}). Type: ${params.type}, Message: "${params.message}"`,
        }],
      };
    },
  });

  pi.registerTool({
    name: "get_messages",
    label: "Get Messages",
    description: "Pull recent notifications from the agent-notify message stream",
    parameters: Type.Object({
      since_id: Type.Optional(Type.Number({ description: "Return only messages with id greater than this. Use 0 for initial fetch." })),
      limit: Type.Optional(Type.Number({ description: "Max messages to return (default 50)" })),
      type: Type.Optional(Type.String({ description: "Filter by notification type" })),
      to: Type.Optional(Type.String({ description: "Filter messages directed to this agent" })),
      project: Type.Optional(Type.String({ description: "Filter by project name" })),
      model: Type.Optional(Type.String({ description: "Filter by model identifier" })),
    }),
    async execute(_toolCallId, params) {
      const result = getMessages(params);
      return {
        content: [{ type: "text", text: JSON.stringify(result, null, 2) }],
      };
    },
  });

  pi.registerTool({
    name: "check_message_status",
    label: "Check Status",
    description: "Check notification playback status — latest_id, last_played_id, has_new, queue_length, and agent activity",
    parameters: Type.Object({
      since_id: Type.Optional(Type.Number({ description: "Check for messages newer than this ID" })),
    }),
    async execute(_toolCallId, params) {
      const result = checkMessageStatus(params);
      return {
        content: [{ type: "text", text: JSON.stringify(result, null, 2) }],
      };
    },
  });

  pi.registerTool({
    name: "check_responses_available",
    label: "Check Responses Available",
    description: "Check if any responses have been sent to a specific message ID",
    parameters: Type.Object({
      id: Type.Number({ description: "The message ID to check for responses to" }),
    }),
    async execute(_toolCallId, params) {
      const result = checkResponses(params, "available");
      return {
        content: [{ type: "text", text: JSON.stringify(result, null, 2) }],
      };
    },
  });

  pi.registerTool({
    name: "check_responses_observed",
    label: "Check Responses Observed",
    description: "Check if responses to a message have been heard by the human (audio played)",
    parameters: Type.Object({
      id: Type.Number({ description: "The message ID to check for observed responses to" }),
    }),
    async execute(_toolCallId, params) {
      const result = checkResponses(params, "observed");
      return {
        content: [{ type: "text", text: JSON.stringify(result, null, 2) }],
      };
    },
  });
}
