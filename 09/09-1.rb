#!/usr/bin/env ruby

# The whole disk is only 95217 blocks long so we can just do this in an array,
# right?

class Disk

  attr_reader :blocks, :used

  def initialize(io)
    @blocks = []
    @filename = 0
    @used = 0
    @data_next = true
    io.each_char do |c|
      if @data_next
        n = c.to_i
        @blocks += Array.new(n, @filename)
        @used += n # remember how much disk space is used because that's how we know when to stop
        @filename += 1
      else
        @blocks += Array.new(c.to_i, nil)
      end
      @data_next = !@data_next
    end
  end

  # "refragment" the disk by moving blocks from the end into free space
  def fragment!
    until blocks.length == used
      puts blocks.length if blocks.length % 100 == 0
      last = blocks.pop
      blocks[blocks.find_index nil] = last if last
    end
  end

  def checksum
    blocks.each_with_index.sum {|f,i| f*i}
  end

end

d = Disk.new(ARGF)
puts "TARGET: #{d.used}"
d.fragment!
p d
p d.checksum
