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
    $db.fetch("select file.repo_path from file natural join bag_file
                where file.image_id is not null
                  and bag_file.bag_id = ?
                order by bag_file.pos", id) { |r| blk.call(r) }
  end

  def list_files_of_bag(id, w, h, &blk)
    $db.fetch("select thumbnail.repo_path from thumbnail, (file
                           natural join bag_file)
                where thumbnail.file_id = file.file_id
                  and bag_file.bag_id = ?
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
    $db.fetch("select bag.bag_id, bag.dir from file natural join
                                               bag_file natural join bag
                group by bag.bag_id, bag.dir
                having count(
                  case when file.image_id is not null then
                    1
                  end) = 0") {
      |r| blk.call(r)
    }
  end

  def list_nonempty_bags_by_page(gap, n, &blk)
    $db.fetch("select bag_id, dir from bag where exists
                 (select * from bag_file natural join file
                 where file.image_id is not null
                   and bag_file.bag_id = bag.bag_id) limit ? offset ? ",
              gap, n * gap) { |r| blk.call(r) }
  end

  def count_bags_nonempty()
    $db.fetch("select count(*) from bag where exists
                 (select * from bag_file natural join file
                 where file.image_id is not null
                   and bag_file.bag_id = bag.bag_id)").first[:count];
  end
  def count_bags_empty()
    $db.fetch("select count(*) from bag where not exists
                 (select * from bag_file natural join file
                 where file.image_id is not null
                   and bag_file.bag_id = bag.bag_id)").first[:count];
  end
end
