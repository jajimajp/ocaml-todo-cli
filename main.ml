open Repo

exception Not_implemented
let not_implemented () = raise Not_implemented

(** CLI state *)
type state =
  | ListTodos
  | ShowTodo of todo_id
  | UpdateTodo of todo_id
  | CreateTodo
  | CompleteTodo of todo_id

let init_state = ListTodos

let rec loop repo = function
  | ListTodos -> (
      let open TodoRepository in
      Printf.printf "===\nNot completed todos:\n";
      list repo
      |> List.iter (fun todo -> Printf.printf "- %s: %s\n" todo.id todo.title);
      print_string {|===
"c" to create a new todo, input an ID to show, or "q" to quit: |};
      Out_channel.flush stdout;
      match read_line () with
      | "c" -> loop repo CreateTodo
      | "q" -> ()
      | c -> loop repo (ShowTodo c)
  )
  | ShowTodo id -> (
      let open TodoRepository in
      let todo = show repo id in
      Printf.printf "===\nTitle: %s (%s)\nCreated at: %s\n===\n"
        todo.title (if todo.completed then "Completed" else "Not completed") todo.created_at;
      let rec prompt () =
        print_string {|"u" to update, "c" to complete, "b" to go back, or "q" to quit: |};
        match read_line () with
        | "u" -> loop repo (UpdateTodo id)
        | "c" -> loop repo (CompleteTodo id)
        | "b" -> loop repo ListTodos
        | "q" -> ()
        | _ -> prompt ()
      in
      prompt ()
  )
  | UpdateTodo id -> (
      let open TodoRepository in
      let todo = show repo id in
      print_string "Enter new title: ";
      Out_channel.flush stdout;
      match read_line () with
      | "" -> loop repo ListTodos
      | title ->
          let updated_todo = { todo with title } in
          update repo updated_todo;
          loop repo ListTodos
  )
  | CreateTodo -> (
      print_string "Enter todo title: ";
      Out_channel.flush stdout;
      match read_line () with
      | "" -> loop repo ListTodos
      | title ->
          let open TodoRepository in
          create repo title;
          loop repo ListTodos
  )
  | CompleteTodo id -> (
      let open TodoRepository in
      let todo = show repo id in
      let updated_todo = { todo with completed = true } in
      update repo updated_todo;
      loop repo ListTodos
  )

let () =
  let db_name = Setup.setup () in
  let open TodoRepository in
  let& repo = make db_name in
  loop repo init_state

