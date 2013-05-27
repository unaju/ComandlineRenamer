#!ruby -Ku

require "kconv"

# マッチ、置換後のペアで無いならエラー
raise ArgumentError if (ARGV.size % 2) != 0
exit if ARGV.empty?

# 引数の""を削除
argv = ARGV.collect{ |v|
  v.sub(/^\"(.*)\"$/, '\1')
}

# 置換処理用データ作成
sub_ptn = (0...(argv.size / 2)).collect{ |i|
  [ Regexp.new(ARGV[i]), ARGV[i+1] ]
}

# ファイルリスト生成. マルチバイト対応のためにDir["*"]は使わない.
fl = Dir.open("./").
  # マルチバイト対応のためutf8化
  collect{ |f| f.toutf8 }.
  # ".."と"."を排除
  reject!{ |f| /^\.+$/ =~ f }.
  # ファイル名を置換前、置換後で分ける
  collect!{ |on|
    nn = on.dup
    sub_ptn.each{ |ptn,rep| nn.sub!(ptn,rep) }
    [on, nn]
  }.
  # 置換されないものを削除
  reject!{ |on, nn| on == nn }

# 置換なしなら終了
exit if fl.empty?

# 置換確認
puts fl.collect{ |on, nn| "#{on} => #{nn}\n" }.join("")
print "ok? [y/n] > "
exit unless STDIN.gets.to_s.chomp.downcase == "y"

# 置換実行
fl.each{ |on, nn| File.rename(on, nn) }



