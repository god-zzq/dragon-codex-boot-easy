[CmdletBinding()]
param([string]$OutputRoot,[string]$VideoPath)
$ErrorActionPreference='Stop'
$repoRoot=[IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
if(!$OutputRoot){$OutputRoot=Join-Path $repoRoot 'assets'}
if(!$VideoPath){$VideoPath=Join-Path $repoRoot 'media/startup.mp4'}
$frameRoot=Join-Path $repoRoot '.local/icon-source'
New-Item -ItemType Directory -Path $OutputRoot,$frameRoot -Force | Out-Null
$frame=Join-Path $frameRoot 'portrait.png'
# Crop the original animation at 3 seconds, around the dragon girl's face and horns.
& ffmpeg -hide_banner -loglevel error -ss 3 -i $VideoPath -vf 'crop=300:300:837:34,scale=512:512:flags=lanczos' -frames:v 1 -y $frame
if($LASTEXITCODE -ne 0){throw 'Unable to extract the original portrait. Install FFmpeg first.'}
Add-Type -AssemblyName System.Drawing
Add-Type -ReferencedAssemblies System.Drawing -TypeDefinition @"
using System;using System.Drawing;using System.Drawing.Drawing2D;using System.Drawing.Imaging;using System.IO;
public static class OriginalDragonIcon {
 public static void Make(string root,string frame){
 using(var source=Image.FromFile(frame))using(var image=new Bitmap(512,512,PixelFormat.Format32bppArgb)){
 using(var g=Graphics.FromImage(image))using(var shape=new GraphicsPath()){
 g.SmoothingMode=SmoothingMode.AntiAlias;g.InterpolationMode=InterpolationMode.HighQualityBicubic;g.Clear(Color.Transparent);
 shape.AddArc(0,0,96,96,180,90);shape.AddArc(416,0,96,96,270,90);shape.AddArc(416,416,96,96,0,90);shape.AddArc(0,416,96,96,90,90);shape.CloseFigure();g.SetClip(shape);g.DrawImage(source,0,0,512,512);
 }
 image.Save(Path.Combine(root,"dragon.png"),ImageFormat.Png);
 int[] sizes={16,24,32,48,64,128,256};byte[][] data=new byte[sizes.Length][];
 for(int i=0;i<sizes.Length;i++){using(var resized=new Bitmap(sizes[i],sizes[i],PixelFormat.Format32bppArgb)){using(var g=Graphics.FromImage(resized)){g.InterpolationMode=InterpolationMode.HighQualityBicubic;g.DrawImage(image,0,0,sizes[i],sizes[i]);}using(var ms=new MemoryStream()){resized.Save(ms,ImageFormat.Png);data[i]=ms.ToArray();}}}
 using(var output=File.Create(Path.Combine(root,"dragon.ico")))using(var w=new BinaryWriter(output)){w.Write((ushort)0);w.Write((ushort)1);w.Write((ushort)sizes.Length);uint offset=(uint)(6+16*sizes.Length);for(int i=0;i<sizes.Length;i++){w.Write((byte)(sizes[i]==256?0:sizes[i]));w.Write((byte)(sizes[i]==256?0:sizes[i]));w.Write((byte)0);w.Write((byte)0);w.Write((ushort)1);w.Write((ushort)32);w.Write((uint)data[i].Length);w.Write(offset);offset+=(uint)data[i].Length;}foreach(var bytes in data)w.Write(bytes);}
 }
 }
}
"@
[OriginalDragonIcon]::Make([IO.Path]::GetFullPath($OutputRoot),$frame)