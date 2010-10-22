helpers do
  def count()
    $db.fetch("select count(*) from set").first[:count]
  end
  def list_sets_by_page(gap, n, &blk)
    $db.fetch("select id, dir from set
                 limit ? offset ? ", gap, n * gap) do |r|
      blk.call(r)
    end
  end
  def list_files_of_set(id, &blk)
    $db.fetch("select file.path from file, set_file
                where file.id = set_file.file_id
                  and file.image = true
                  and set_file.set_id = ?
                order by set_file.pos", id) { |r| blk.call(r) }
  end



  # ugly
  def list_empty_sets(&blk)
    $db.fetch("select set.id, set.dir from set_file, set, file
                where set_file.set_id = set.id
                  and set_file.file_id = file.id
                group by set.id, set.dir
                having count(case when
                              file.image then 1 end) = 0") { |r| blk.call(r) }
  end

  def list_nonempty_sets_by_page(gap, n, &blk)
    $db.fetch("select id, dir from set where exists
                 (select * from set_file join file on
                    (set_file.file_id = file.id)
                 where file.image
                   and set_file.set_id = set.id) limit ? offset ? ",
              gap, n * gap) { |r| blk.call(r) }
  end



  def count_sets_nonempty()
    $db.fetch("select count(*) from set where exists
                 (select * from set_file join file on
                    (set_file.file_id = file.id)
                 where file.image
                   and set_file.set_id = set.id)").first[:count];
  end
  def count_sets_empty()
    $db.fetch("select count(*) from set where not exists
                 (select * from set_file join file on
                    (set_file.file_id = file.id)
                 where file.image
                   and set_file.set_id = set.id)").first[:count];
  end
end
