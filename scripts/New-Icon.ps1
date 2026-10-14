param([string]$OutputRoot)
$ErrorActionPreference='Stop'
Add-Type -AssemblyName System.Drawing
New-Item -ItemType Directory -Path $OutputRoot -Force | Out-Null
Add-Type -ReferencedAssemblies System.Drawing -TypeDefinition @"
using System;using System.Drawing;using System.Drawing.Drawing2D;using System.Drawing.Imaging;using System.IO;
public static class DragonIcon {
 static Brush B(string hex){return new SolidBrush(ColorTranslator.FromHtml(hex));}
 static void Poly(Graphics g,string color,params PointF[] points){using(var b=B(color))g.FillPolygon(b,points);}
 static PointF P(float x,float y){return new PointF(x,y);}
 public static void Make(string root){
 using(var image=new Bitmap(512,512,PixelFormat.Format32bppArgb)){
 using(var g=Graphics.FromImage(image)){
 g.SmoothingMode=SmoothingMode.AntiAlias;g.Clear(Color.Transparent);
 using(var bg=new LinearGradientBrush(new Rectangle(20,20,472,472),ColorTranslator.FromHtml("#37245E"),ColorTranslator.FromHtml("#8155B9"),45f))g.FillEllipse(bg,20,20,472,472);
 using(var b=B("#CAB8F6"))g.FillEllipse(b,104,129,304,351);
 Poly(g,"#EEE3FC",P(111,198),P(78,84),P(124,107),P(176,161));
 Poly(g,"#EEE3FC",P(401,198),P(434,84),P(388,107),P(336,161));
 Poly(g,"#AD83DC",P(118,164),P(93,104),P(136,145));
 Poly(g,"#AD83DC",P(394,164),P(419,104),P(376,145));
 using(var b=B("#674293")){g.FillEllipse(b,93,157,71,271);g.FillEllipse(b,348,157,71,271);}
 using(var b=B("#FFE7DA"))g.FillEllipse(b,151,178,210,243);
 using(var b=B("#E9DEFC"))g.FillEllipse(b,141,135,230,106);
 Poly(g,"#E9DEFC",P(149,190),P(168,287),P(215,218),P(245,278),P(276,208),P(325,273),P(365,188));
 using(var b=B("#34244D")){g.FillEllipse(b,182,279,28,46);g.FillEllipse(b,302,279,28,46);}
 using(var b=B("#FFFFFF")){g.FillEllipse(b,188,283,9,13);g.FillEllipse(b,308,283,9,13);}
 using(var b=B("#EEA4B7")){g.FillEllipse(b,162,326,43,17);g.FillEllipse(b,307,326,43,17);}
 using(var pen=new Pen(ColorTranslator.FromHtml("#9B526E"),7)){pen.StartCap=LineCap.Round;pen.EndCap=LineCap.Round;g.DrawArc(pen,238,329,37,30,20,140);}
 using(var b=B("#CAB8F6")){g.FillEllipse(b,109,184,42,252);g.FillEllipse(b,360,184,42,252);}
 Poly(g,"#FFF3BF",P(419,357),P(425,376),P(444,382),P(425,388),P(419,407),P(413,388),P(394,382),P(413,376));
 }
 image.Save(Path.Combine(root,"dragon.png"),ImageFormat.Png);
 int[] sizes={16,24,32,48,64,128,256};byte[][] data=new byte[sizes.Length][];
 for(int i=0;i<sizes.Length;i++){using(var resized=new Bitmap(sizes[i],sizes[i],PixelFormat.Format32bppArgb)){using(var g=Graphics.FromImage(resized)){g.InterpolationMode=InterpolationMode.HighQualityBicubic;g.DrawImage(image,0,0,sizes[i],sizes[i]);}using(var ms=new MemoryStream()){resized.Save(ms,ImageFormat.Png);data[i]=ms.ToArray();}}}
 using(var output=File.Create(Path.Combine(root,"dragon.ico")))using(var w=new BinaryWriter(output)){w.Write((ushort)0);w.Write((ushort)1);w.Write((ushort)sizes.Length);uint offset=(uint)(6+16*sizes.Length);for(int i=0;i<sizes.Length;i++){w.Write((byte)(sizes[i]==256?0:sizes[i]));w.Write((byte)(sizes[i]==256?0:sizes[i]));w.Write((byte)0);w.Write((byte)0);w.Write((ushort)1);w.Write((ushort)32);w.Write((uint)data[i].Length);w.Write(offset);offset+=(uint)data[i].Length;}foreach(var bytes in data)w.Write(bytes);}
 }
 }
}
"@
[DragonIcon]::Make([IO.Path]::GetFullPath($OutputRoot))