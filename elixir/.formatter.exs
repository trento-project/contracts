# SPDX-FileCopyrightText: SUSE LLC
# SPDX-License-Identifier: GPL-3.0-or-later

# Used by "mix format"
[
  inputs: ["{mix,.formatter}.exs", "{config,test}/**/*.{ex,exs}", "lib/*.ex"],
  import_deps: [:protobuf]
]
