import assert from "node:assert/strict";

export const apiBaseUrl = process.env.API_BASE_URL ?? "http://127.0.0.1:8787";

export type HarnessClient = ReturnType<typeof createHarnessClient>;

export function createHarnessClient(testId: string) {
  let token = "";
  const request = async (
    path: string,
    options: {
      method?: string;
      body?: unknown;
      rawBody?: string;
      expected?: number | number[];
      auth?: boolean;
      headers?: Record<string, string>;
    } = {},
  ) => {
    const response = await fetch(`${apiBaseUrl}${path}`, {
      method: options.method ?? "GET",
      headers: {
        ...(options.body !== undefined || options.rawBody !== undefined
          ? { "content-type": "application/json" }
          : {}),
        ...(options.auth !== false && token
          ? { authorization: `Bearer ${token}` }
          : {}),
        ...options.headers,
      },
      body:
        options.rawBody ??
        (options.body === undefined ? undefined : JSON.stringify(options.body)),
    });
    const text = await response.text();
    let data: any = text;
    try {
      data = text ? JSON.parse(text) : null;
    } catch {
      /* adversarial responses may be text */
    }
    const expected = Array.isArray(options.expected)
      ? options.expected
      : [options.expected ?? 200];
    assert.ok(
      expected.includes(response.status),
      `${testId}: ${options.method ?? "GET"} ${path} returned ${response.status}: ${text}`,
    );
    return { response, data };
  };
  return {
    request,
    get token() {
      return token;
    },
    setToken(value: string) {
      token = value;
    },
    async register(name = testId) {
      const stamp = `${testId.toLowerCase()}-${Date.now()}-${Math.random().toString(16).slice(2)}`;
      const result = await request("/v1/auth/register", {
        method: "POST",
        auth: false,
        expected: 201,
        body: {
          email: `${stamp}@harness.sprout.test`,
          password: "Harness!246810",
          name,
          deviceId: stamp,
          deviceName: "Harness runner",
        },
      });
      token = result.data.accessToken;
      await request("/v1/profile/onboarding", {
        method: "POST",
        body: { name },
      });
      return result.data;
    },
  };
}
