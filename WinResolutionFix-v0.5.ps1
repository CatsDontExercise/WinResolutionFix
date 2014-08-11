cls

#About.me
#not finished
#Script to detect primary screen resoultion in windows 8/2012 and based on user inactivity attempt to enforce desired resolution settings.
#Goal is to remediate issues with HDMI signal sensing 

# How long after user inactivity to trigger resolution check. hours mins seconds ms
$WaitPeriod = "00:00:00.0100000"


#http://blogs.technet.com/b/heyscriptingguy/archive/2010/07/07/hey-scripting-guy-how-can-i-change-my-desktop-monitor-resolution-via-windows-powershell.aspx
#http://technet.microsoft.com/en-us/library/jj603037.aspx
#http://msdn.microsoft.com/en-us/library/windows/desktop/ms646302%28v=vs.85%29.aspx
#http://technet.microsoft.com/en-us/library/jj603036.aspx



#User inactivity functionality from http://stackoverflow.com/questions/15845508/get-idle-time-of-machine
Add-Type @'
using System;
using System.Diagnostics;
using System.Runtime.InteropServices;

namespace PInvoke.Win32 {

    public static class UserInput {

        [DllImport("user32.dll", SetLastError=false)]
        private static extern bool GetLastInputInfo(ref LASTINPUTINFO plii);

        [StructLayout(LayoutKind.Sequential)]
        private struct LASTINPUTINFO {
            public uint cbSize;
            public int dwTime;
        }

        public static DateTime LastInput {
            get {
                DateTime bootTime = DateTime.UtcNow.AddMilliseconds(-Environment.TickCount);
                DateTime lastInput = bootTime.AddMilliseconds(LastInputTicks);
                return lastInput;
            }
        }

        public static TimeSpan IdleTime {
            get {
                return DateTime.UtcNow.Subtract(LastInput);
            }
        }

        public static int LastInputTicks {
            get {
                LASTINPUTINFO lii = new LASTINPUTINFO();
                lii.cbSize = (uint)Marshal.SizeOf(typeof(LASTINPUTINFO));
                GetLastInputInfo(ref lii);
                return lii.dwTime;
            }
        }
    }
}
'@




$Idle = ([PInvoke.Win32.UserInput]::IdleTime)
write-host $Idle
If ($Idle -gt $WaitPeriod) {


$CurrentResolution = Get-DisplayResolution
write-host $CurrentResolution
If ($CurrentResolution -ne "1920x1080") {Set-DisplayResolution -Width 1920 -Height 1080 -Force}
}

