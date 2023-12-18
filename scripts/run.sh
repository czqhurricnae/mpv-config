cd "/Users/c/Downloads/mpv-www-gen"
mkdir .cut_video
ffmpeg   -i Combination\ of\ SAR\ and\ Optical\ Sensors\ is\ future-\ Massimo\ Claudio\ Comparini\,\ CEO\,\ e-geos.mp4 -ss 18.6186 -t 2.736066666667 .cut_video/clip0.mp4
echo "file 'clip0.mp4'" >>.cut_video/concat.txt
ffmpeg   -i Combination\ of\ SAR\ and\ Optical\ Sensors\ is\ future-\ Massimo\ Claudio\ Comparini\,\ CEO\,\ e-geos.mp4 -ss 32.298933333333 -t 10.410400000000 .cut_video/clip1.mp4
echo "file 'clip1.mp4'" >>.cut_video/concat.txt
ffmpeg   -i Combination\ of\ SAR\ and\ Optical\ Sensors\ is\ future-\ Massimo\ Claudio\ Comparini\,\ CEO\,\ e-geos.mp4 -ss 51.584866666667 -t 2.802800000000 .cut_video/clip2.mp4
echo "file 'clip2.mp4'" >>.cut_video/concat.txt
ffmpeg   -i Combination\ of\ SAR\ and\ Optical\ Sensors\ is\ future-\ Massimo\ Claudio\ Comparini\,\ CEO\,\ e-geos.mp4 -ss 65.231833333333 -t 10.510500000000 .cut_video/clip3.mp4
echo "file 'clip3.mp4'" >>.cut_video/concat.txt
ffmpeg   -i Combination\ of\ SAR\ and\ Optical\ Sensors\ is\ future-\ Massimo\ Claudio\ Comparini\,\ CEO\,\ e-geos.mp4 -ss 86.319566666667 -t -11.578233333334 .cut_video/clip4.mp4
echo "file 'clip4.mp4'" >>.cut_video/concat.txt
ffmpeg   -i Combination\ of\ SAR\ and\ Optical\ Sensors\ is\ future-\ Massimo\ Claudio\ Comparini\,\ CEO\,\ e-geos.mp4 -ss 98.3983 -t 5.33866666667 .cut_video/clip5.mp4
echo "file 'clip5.mp4'" >>.cut_video/concat.txt
ffmpeg   -i Combination\ of\ SAR\ and\ Optical\ Sensors\ is\ future-\ Massimo\ Claudio\ Comparini\,\ CEO\,\ e-geos.mp4 -ss 125.39193333333 -t 7.14046666667 .cut_video/clip6.mp4
echo "file 'clip6.mp4'" >>.cut_video/concat.txt
ffmpeg   -i Combination\ of\ SAR\ and\ Optical\ Sensors\ is\ future-\ Massimo\ Claudio\ Comparini\,\ CEO\,\ e-geos.mp4 -ss 139.60613333333 -t 2.90290000000 .cut_video/clip7.mp4
echo "file 'clip7.mp4'" >>.cut_video/concat.txt
ffmpeg -f concat -i .cut_video/concat.txt -c copy "`date "+%Y_%m_%d_%H_%M_%S"`_cut_Combination of SAR and Optical Sensors is future- Massimo Claudio Comparini, CEO, e-geos.mp4"
echo -----ok!-----
