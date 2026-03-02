using System;
using System.Text.Json.Serialization;

namespace PrintBridge
{
    public sealed class BridgeMeta
    {
        [JsonPropertyName("bridge")]
        public string Bridge { get; set; } = "print_bridge";

        [JsonPropertyName("version")]
        public string Version { get; set; } = "1.0.0";

        [JsonPropertyName("ts")]
        public string Ts { get; set; } = DateTimeOffset.UtcNow.ToString("o");

        [JsonPropertyName("requestId")]
        public string RequestId { get; set; } = "";
    }

    public sealed class BridgeError
    {
        [JsonPropertyName("code")]
        public string Code { get; set; } = "UNKNOWN";

        [JsonPropertyName("message")]
        public string Message { get; set; } = "Unknown error";

        [JsonPropertyName("details")]
        public string Details { get; set; } = "";
    }

    public sealed class BridgeResponse<T>
    {
        [JsonPropertyName("ok")]
        public bool Ok { get; set; }

        [JsonPropertyName("meta")]
        public BridgeMeta Meta { get; set; } = new BridgeMeta();

        [JsonPropertyName("data")]
        [JsonIgnore(Condition = JsonIgnoreCondition.WhenWritingNull)]
        public T? Data { get; set; }

        [JsonPropertyName("error")]
        [JsonIgnore(Condition = JsonIgnoreCondition.WhenWritingNull)]
        public BridgeError? Error { get; set; }
    }

    public sealed class HealthData
    {
        [JsonPropertyName("status")]
        public string Status { get; set; } = "ok";
    }

    public sealed class PrintData
    {
        [JsonPropertyName("printer")]
        public string Printer { get; set; } = "";

        [JsonPropertyName("copies")]
        public int Copies { get; set; }

        [JsonPropertyName("bytesSent")]
        public int BytesSent { get; set; }

        [JsonPropertyName("testMode")]
        public bool TestMode { get; set; }

        [JsonPropertyName("zplPreview")]
        [JsonIgnore(Condition = JsonIgnoreCondition.WhenWritingNull)]
        public string? ZplPreview { get; set; }

        [JsonPropertyName("outPath")]
        [JsonIgnore(Condition = JsonIgnoreCondition.WhenWritingNull)]
        public string? OutPath { get; set; }
    }
}