exception Usage_error of string

let fail_usage s = raise (Usage_error s)
