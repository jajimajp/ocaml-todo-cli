(** [setup_dir] setups file path for app and returns db path. *)
let setup_dir : unit -> string = fun () ->
  let data_dir = "@DATADIR@" (* preprocessed *) in
  if Sys.file_exists data_dir then
    data_dir ^ "/ocaml-todo-cli.db"
  else
    failwith "Cound not setup database"

let setup_db db_name =
    let query = {|create table if not exists todos
  ( id integer primary key autoincrement
  , title text not null
  , completed integer not null default false
  , created_at not null
  );|} in
    let open Sqlite3 in
    let& db = db_open db_name in
    let rc = exec db query in
    if Rc.is_success rc then ()
    else
      (Rc.to_string rc |> print_endline; failwith "setup failed")

let setup () =
  let db_name = setup_dir () in
  setup_db db_name;
  db_name

