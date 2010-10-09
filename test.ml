let create_table dbh =
  PGSQL(dbh) "execute"
    "create temporary table users
       (id    serial primary key,
        name  text not null,
        age   int not null)"

let insert_user dbh name age =
  PGSQL(dbh) "INSERT INTO users (name, age)
                     VALUES ($name, $age)"
let get_users dbh =
  PGSQL(dbh) "SELECT id, name, age FROM users"
let print_user (id, name, age) =
  Printf.printf "Id: %ld Name: %s
Age: %ld \n" id name age

let _ =
  let dbh = PGOCaml.connect () in
  let () = create_table dbh in
  let () =
    insert_user dbh "John" 30l;
    insert_user dbh "Mary" 40l;
    insert_user dbh "Mark" 42l in
    List.iter print_user (get_users dbh)
