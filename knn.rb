require "zlib"

require 'csv'

train_data = CSV.read("train.csv")

test_data = "Some People Not Eligible to Get in on Google IPO, Google has billed its IPO as a way for everyday people to get in on the process, denying Wall Street the usual stranglehold it's had on IPOs. Public bidding, a minimum of just five shares, an open process with 28 underwriters - all this pointed to a new level of public participation. But this isn't the case."

ncds = []


train_data.each_with_index do |t, i|
  # x is train
  # y is test
  next if i == 0
  train_line = t[1] + t[2]
  cxy = Zlib::Deflate.deflate(train_line + " " + test_data)
  cx = Zlib::Deflate.deflate(train_line)
  cy = Zlib::Deflate.deflate(test_data)

  ncd = (cxy.length - [cx, cy].min.length) / [cx, cy].max.length.to_f

  ncds << [ncd, t[0]]
end



ncds = ncds.sort_by(&:first)

def predict_class(a)
  freq =  a.inject(Hash.new(0)) { |h,v| h[v] += 1; h }

  predected =  a.max_by { |v| freq[v] }
  return predected[1]
end

puts predict_class(ncds[0..2])
