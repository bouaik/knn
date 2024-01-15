require "zlib"

require 'csv'

train_data = CSV.read("train_small.csv")

test_data = CSV.read("test.csv")


def predict_class(a)
  freq =  a.inject(Hash.new(0)) { |h,v| h[v] += 1; h }

  predected =  a.max_by { |v| freq[v] }
  return predected[1]
end
success = 0


starting = Process.clock_gettime(Process::CLOCK_MONOTONIC)

test_data.each_with_index do |e, j|
  next if j == 0
  test_line = e[1] + e[2]

  ncds = []



  train_data.each_with_index do |t, i|
    # x is train
    # y is test
    next if i == 0
    train_line = t[1] + t[2]
    cxy = Zlib::Deflate.deflate(train_line + " " + test_line)
    cx = Zlib::Deflate.deflate(train_line)
    cy = Zlib::Deflate.deflate(test_line)

    ncd = (cxy.length - [cx, cy].min.length) / [cx, cy].max.length.to_f

    ncds << [ncd, t[0]]
  end

  ncds = ncds.sort_by(&:first)


  success += 1 if predict_class(ncds[0..2]) == e[0]

end

ending = Process.clock_gettime(Process::CLOCK_MONOTONIC)

elapsed = ending - starting


text =  "Success is #{success} over #{test_data.length - 1} \nSuccess rate is #{success / (test_data.length - 1).to_f} \nElapsed time is #{elapsed}"


out_file = File.new("results.txt", "w")
out_file.puts(text)
out_file.close
