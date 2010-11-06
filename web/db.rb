def def_size()
  a = $db.fetch("select def_width, def_height from config").first;
  "#{a[:def_width]}x#{a[:def_height]}"
end

def sizes()
  a = $db.fetch("select width, height from thumbnail_size order by width * height desc").first(3)
  a.map { |a| "#{a[:width]}x#{a[:height]}" }
end

helpers do
  def link_file repo_path
    repo_path.sub %r{^/[^/]+/[^/]+/[^/]+}, "http://127.0.0.1:4567/#{$pre_dir}"
  end

  def count()
    $db.fetch("select count(*) from bag").first[:count]
  end
  def list_bags_by_page(gap, n, &blk)
    $db.fetch("select bag_id, dir from bag
                 limit ? offset ? ", gap, n * gap) do |r|
      blk.call(r)
    end
  end
  def list_files_of_bag_(id, &blk)
    $db.fetch("select file.repo_path from file natural join image
                                               natural join bag_file
                where bag_file.bag_id = ?
                order by bag_file.pos", id) { |r| blk.call(r) }
  end

  def list_files_of_bag(id, w, h, &blk)
    $db.fetch("select f.repo_path from (thumbnail natural join file as f) join (file
                                                         natural join bag_file)
                   on thumbnail.parent_id = file.file_id
                where bag_file.bag_id = ?
                  and thumbnail.max_width = ?
                  and thumbnail.max_height = ?
                order by bag_file.pos", id, w, h) { |r| blk.call(r) }
  end

  def list_files_with_type(t, id, &blk)
    def f x
      x.split(/x/) if x =~ /x/
    end

    if t == 'hi-res'
      list_files_of_bag_(id) { |r| blk.call(r) }
    else
      w, h = f t
      list_files_of_bag(id, w, h) { |r| blk.call(r) }
    end
  end

  # ugly
  def list_empty_bags(&blk)
    $db.fetch("select bag.bag_id, bag.dir from file natural join image natural join
                                               bag_file natural join bag
                group by bag.bag_id, bag.dir
                having count(*) = 0") {
      |r| blk.call(r)
    }
  end

  def list_nonempty_bags_by_page(gap, n, &blk)
    $db.fetch("select bag_id, dir from bag where exists
                 (select * from file natural join image natural join bag_file
                 where bag_file.bag_id = bag.bag_id) limit ? offset ? ",
              gap, n * gap) { |r| blk.call(r) }
  end

  def count_bags_nonempty()
    $db.fetch("select count(*) from bag where exists
                 (select * from file natural join image natural join bag_file
                 where bag_file.bag_id = bag.bag_id)").first[:count];
  end
  def count_bags_empty()
    $db.fetch("select count(*) from bag where not exists
                 (select * from file natural join image natural join bag_file
                 where bag_file.bag_id = bag.bag_id)").first[:count];
  end
end
