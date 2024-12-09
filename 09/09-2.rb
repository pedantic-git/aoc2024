#!/usr/bin/env ruby

# For part 2 using a more traditional FAT will be the best option

require 'pp'
Alloc = Struct.new(:filename, :start, :length) do
  def checksum
    start.upto(start+length-1).sum { _1*filename }
  end
end

class Disk

  attr_reader :files, :last_filename

  def initialize(io)
    @files = []
    data_next = true
    pointer = 0
    filename = 0
    io.each_char do |c|
      length = c.to_i
      if data_next
        @files << Alloc.new(filename, pointer, length)
        filename += 1
      end
      pointer += length
      data_next = !data_next
    end
    @last_filename = filename-1
  end

  # Calculate the amount of space after the given filename
  def space_after(index)
    a = files[index] or return 0
    n = files[index+1] or return 0
    n.start - (a.start + a.length)
  end

  # Given a filename, move it into the first available space large enough to
  # hold it
  def move_file!(index)
    alloc = files[index]
    # First, find the index with enough space after it
    insert_after = files.each_index.find {|i| i < index && space_after(i) >= alloc.length}
    return if insert_after.nil?

    # Now splice the file into the new location
    alloc.start = files[insert_after].start + files[insert_after].length
    files.insert(insert_after+1, files.delete_at(index))
  end

  # Runs move_file! on every file, starting at the end. Finds the files instead
  # of iterating by index because they keep moving
  def defrag!
    last_filename.downto(0) do |fn|
      move_file! files.find_index {_1.filename == fn}
    end
  end

  def checksum
    files.sum(&:checksum)
  end

end

d = Disk.new(ARGF)
d.defrag!
p d.checksum