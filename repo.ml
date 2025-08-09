type todo_id = string

type todo =
  { id : todo_id
  ; title : string
  ; completed : bool
  ; created_at : string
  }

module TodoRepository = struct
  type t = Sqlite3.db

  let make db_name = Sqlite3.db_open db_name

  let ( let& ) t f = Sqlite3.(let&) t f

  let show t id =
    let res : todo option ref = ref None in
    let open Sqlite3.Data in
    let f data =
      match data with
      | [| INT id; TEXT title; INT completed; TEXT created_at |] ->
        res := Some { id=Int64.to_string id; title; completed = completed = Int64.of_int 1; created_at }
      | _ -> ()
    in
    let stmt =
      Sqlite3.prepare t
        {|select id, title, completed, created_at
          from todos
          where id=?;|}
    in
    ignore @@ Sqlite3.bind_text stmt 1 id;
    ignore @@ Sqlite3.iter ~f stmt;
    !res |> Option.get

  let list t =
    let res = ref [] in
    let cb row_not_null =
      match row_not_null with
      | [| id; title; completed; created_at |] ->
        res := { id; title; completed = completed = "1"; created_at } :: !res
      | _ -> ()
    in
    ignore @@ Sqlite3.exec_not_null_no_headers t ~cb
      {|select id, title, completed, created_at
        from todos
        where completed = false
        order by created_at desc;|};
    List.rev !res

  let create t title =
    let stmt =
      Sqlite3.prepare t
        {|insert into todos (title, created_at)
values (?, datetime('now', 'localtime'));|}
    in
    ignore @@ Sqlite3.bind_text stmt 1 title;
    ignore @@ Sqlite3.step stmt

  let update t todo =
    let stmt =
      Sqlite3.prepare t
        {|update todos set title = ?, completed = ? where id = ?;|}
    in
    ignore @@ Sqlite3.bind_text stmt 1 todo.title;
    ignore @@ Sqlite3.bind_int stmt 2 (if todo.completed then 1 else 0);
    ignore @@ Sqlite3.bind_text stmt 3 todo.id;
    ignore @@ Sqlite3.step stmt
end

