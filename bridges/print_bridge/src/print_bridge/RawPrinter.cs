using System;
using System.ComponentModel;
using System.Runtime.InteropServices;
using System.Text;

namespace PrintBridge
{
    internal static class RawPrinter
    {
        [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Unicode)]
        private struct DOC_INFO_1
        {
            [MarshalAs(UnmanagedType.LPWStr)]
            public string pDocName;

            [MarshalAs(UnmanagedType.LPWStr)]
            public string pOutputFile;

            [MarshalAs(UnmanagedType.LPWStr)]
            public string pDataType;
        }

        [DllImport("winspool.Drv", SetLastError = true, CharSet = CharSet.Unicode)]
        private static extern bool OpenPrinter(string pPrinterName, out IntPtr phPrinter, IntPtr pDefault);

        [DllImport("winspool.Drv", SetLastError = true)]
        private static extern bool ClosePrinter(IntPtr hPrinter);

        [DllImport("winspool.Drv", SetLastError = true, CharSet = CharSet.Unicode)]
        private static extern int StartDocPrinter(IntPtr hPrinter, int level, ref DOC_INFO_1 di);

        [DllImport("winspool.Drv", SetLastError = true)]
        private static extern bool EndDocPrinter(IntPtr hPrinter);

        [DllImport("winspool.Drv", SetLastError = true)]
        private static extern bool StartPagePrinter(IntPtr hPrinter);

        [DllImport("winspool.Drv", SetLastError = true)]
        private static extern bool EndPagePrinter(IntPtr hPrinter);

        [DllImport("winspool.Drv", SetLastError = true)]
        private static extern bool WritePrinter(IntPtr hPrinter, IntPtr pBytes, int dwCount, out int dwWritten);

        public static int SendStringToPrinter(string printerName, string content, string docName = "ZPL Job")
        {
            // Default: ASCII, suficiente para códigos y textos simples.
            // Si necesitas UTF-8 real en Zebra: hay que usar ^CI28 y enviar bytes UTF-8.
            byte[] bytes = Encoding.ASCII.GetBytes(content);
            return SendBytesToPrinter(printerName, bytes, docName);
        }

        public static int SendBytesToPrinter(string printerName, byte[] bytes, string docName = "ZPL Job")
        {
            if (string.IsNullOrWhiteSpace(printerName))
                throw new ArgumentException("printerName is required");

            IntPtr hPrinter = IntPtr.Zero;
            IntPtr pUnmanagedBytes = IntPtr.Zero;

            try
            {
                if (!OpenPrinter(printerName, out hPrinter, IntPtr.Zero) || hPrinter == IntPtr.Zero)
                    throw new Win32Exception(Marshal.GetLastWin32Error(), "OpenPrinter failed");

                var di = new DOC_INFO_1
                {
                    pDocName = docName,
                    pOutputFile = null!,
                    pDataType = "RAW"
                };

                int jobId = StartDocPrinter(hPrinter, 1, ref di);
                if (jobId <= 0)
                    throw new Win32Exception(Marshal.GetLastWin32Error(), "StartDocPrinter failed");

                if (!StartPagePrinter(hPrinter))
                    throw new Win32Exception(Marshal.GetLastWin32Error(), "StartPagePrinter failed");

                pUnmanagedBytes = Marshal.AllocHGlobal(bytes.Length);
                Marshal.Copy(bytes, 0, pUnmanagedBytes, bytes.Length);

                if (!WritePrinter(hPrinter, pUnmanagedBytes, bytes.Length, out int written))
                    throw new Win32Exception(Marshal.GetLastWin32Error(), "WritePrinter failed");

                if (!EndPagePrinter(hPrinter))
                    throw new Win32Exception(Marshal.GetLastWin32Error(), "EndPagePrinter failed");

                if (!EndDocPrinter(hPrinter))
                    throw new Win32Exception(Marshal.GetLastWin32Error(), "EndDocPrinter failed");

                return written;
            }
            finally
            {
                if (pUnmanagedBytes != IntPtr.Zero)
                    Marshal.FreeHGlobal(pUnmanagedBytes);

                if (hPrinter != IntPtr.Zero)
                    ClosePrinter(hPrinter);
            }
        }
    }
}