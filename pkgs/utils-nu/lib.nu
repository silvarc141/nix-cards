# Pulls nested tables and lists into higher level extra numbered columns, a kind of deep flatten
export def pull-table-up-to-columns [] {
  let table = $in
  let columns = ($table | first | columns)
  mut result = $table

  for $col in $columns {
    let col_values = ($table | get $col)

    let first_non_null = ($col_values | where not ($it == null) | first)
    if ($first_non_null == null) { continue }

    let first_non_null_desc = ($first_non_null | describe)
    if not ($first_non_null_desc =~ "list" or $first_non_null_desc =~ "table") { continue }

    let first_nested = ($first_non_null | first)
    if ($first_nested == null) { continue }
    if not (($first_nested | describe) =~ "record") { continue }

    let max_records_count = ($col_values | where not ($it == null) | each { |row| $row | length } | math max)

    for $id in 0..($max_records_count - 1) {
      for $name in ($first_non_null | columns) {
        let new_col_name = $"($col)-($id + 1)-($name)"
        $result = ($result | insert $new_col_name null)
      }
    }

    for $row in ($col_values | enumerate) {
      for $nested_row in ($row.item | enumerate) {
        for $nested_column_name in ($nested_row.item | columns) {
          let value = ($nested_row.item | get $nested_column_name)
          let new_col_name = $"($col)-($nested_row.index + 1)-($nested_column_name)"
          $result = ($result | update $row.index {|c| $c | update $new_col_name $value })
        }
      }
    }

    $result = ($result | reject $col)
  }

  $result
}

# Removes all columns which names start with the word "meta"
export def remove-meta [] {
  let input = $in
  let type = ($input | describe)

  match $type {
    $t if ($t =~ "record") => {
      let cols = ($input | columns)
      let filtered_cols = ($cols | where {|col| not ($col | str starts-with "meta")})
      let result = ($input | select ...$filtered_cols)

      $result | transpose k v | each {|row|
        let value = $row.v
        let key = $row.k
        {$key: ($value | remove-meta)}
      } | reduce -f {} {|it, acc| $acc | merge $it}
    }
    $t if ($t =~ "list") => {
      $input | each {|item| $item | remove-meta}
    }
    _ => $input
  }
}

# Duplicates each element n times in provided list or table, n being "count" property/column if it exist, otherwise skip, finally reject "count" property/column
export def expand-count [] {
  let input = $in
  let type = ($input | describe)

  match $type {
    $t if ($t =~ "record") => {
      if not ("count" in ($input | columns)) {
        $input
      } else {
        let count = ($input | get count)
        if $count == 0 {
          []
        } else {
          let result = ($input | reject count)
          1..$count | each {|| $result }
        }
      }
    }
    $t if ($t =~ "table") => {
      if not ("count" in ($input | columns)) {
        $input
      } else {
        $input | each {|row|
          let count = ($row.count)
          if $count == 0 {
            []
          } else {
            let result = ($row | reject count)
            1..$count | each {|| $result }
          }
        } | flatten
      }
    }
    $t if ($t =~ "list") => {
      $input | each {|item|
        if ($item | describe) =~ "record" and ("count" in ($item | columns)) {
          let count = ($item.count)
          if $count == 0 {
            []
          } else {
            let result = ($item | reject count)
            1..$count | each {|| $result }
          }
        } else {
          $item
        }
      } | flatten
    }
    _ => $input
  }
}
