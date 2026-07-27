using System;
using System.IO;
using DotNetEnv;
using RtttNetClientAPI;

class Program {
    static void Main(string[] args) {

        Env.Load();

        string[] radarIps = Environment
            .GetEnvironmentVariable("RADAR_IPS")!
            .Split(',');

        var radar1 = new RadarController(radarIps[0].Trim());
        var radar2 = new RadarController(radarIps[1].Trim());
        
        radar1.Connect();
        radar2.Connect();
      
        using (var reader1 = new StreamReader("radar_commands.lua"))
        using (var reader2 = new StreamReader("radar_commands.lua"))
        {
            string? line1;
            string? line2;

            while (!reader1.EndOfStream || !reader2.EndOfStream)
            {
                line1 = reader1.EndOfStream ? null : reader1.ReadLine();
                line2 = reader2.EndOfStream ? null : reader2.ReadLine();

                if (line1 != null)
                {
                    radar1.Execute(line1);
                }

                if (line2 != null)
                {
                    radar2.Execute(line2);
                }
            }
        }
        
        radar1.Disconnect();
        radar2.Disconnect();
    }
}
