open Ocamlbuild_plugin

(* ocamlfind integration following http://www.nabble.com/forum/ViewPost.jtp?post=15979274 *)

let run_command cmd = 
  let chan = Unix.open_process_in cmd in
  let out =
    let rec loop xs =
      match input_line chan with
      | x -> loop (x :: xs)
      | exception End_of_file -> List.rev xs
    in loop []
  in
  match Unix.close_process_in chan with
  | Unix.WEXITED 0 -> `Ok out
  | x -> `Error x

(* this lists all supported packages *)
let find_packages () =
  match run_command "ocamlfind list | cut -d' ' -f1" with
  | `Ok xs -> xs
  | `Error _ -> failwith "Failed to find packages."

(* this lists all supported packages *)
let find_syntaxes () = ["camlp4o"]

(* ocamlfind command *)
let ocamlfind x = S[A"ocamlfind"; x]

;;

dispatch begin function
  | Before_options ->

      (* override default commands by ocamlfind ones *)
       Options.ocamlc   := ocamlfind & A"ocamlc";
       Options.ocamlopt := ocamlfind & A"ocamlopt";
       Options.ocamldep := ocamlfind & A"ocamldep";
       Options.ocamldoc := ocamlfind & A"ocamldoc"

  | After_rules ->

      (* When one link an OCaml library/binary/package, one should use -linkpkg *)
       flag ["ocaml"; "compile"] (S[A"-dtypes"]);
       flag ["ocaml"; "compile"] (S[A"-ppopt"; A"-lwt-debug"]);

       flag ["ocaml"; "link"] & A"-linkpkg";

       (* For each ocamlfind package one inject the -package option when
        * compiling, computing dependencies, generating documentation and
        * linking. *)
       List.iter begin fun pkg ->
         flag ["ocaml"; "compile";  "pkg_"^pkg] & S[A"-package"; A pkg];
         flag ["ocaml"; "ocamldep"; "pkg_"^pkg] & S[A"-package"; A pkg];
         flag ["ocaml"; "doc";      "pkg_"^pkg] & S[A"-package"; A pkg];
         flag ["ocaml"; "link";     "pkg_"^pkg] & S[A"-package"; A pkg];
       end (find_packages ());

       List.iter begin fun syntax ->
         flag ["ocaml"; "compile";  "syntax_"^syntax] & S[A"-syntax"; A syntax];
         flag ["ocaml"; "ocamldep"; "syntax_"^syntax] & S[A"-syntax"; A syntax];
         flag ["ocaml"; "doc";      "syntax_"^syntax] & S[A"-syntax"; A syntax];
       end (find_syntaxes ());

  | _ -> ()
end
