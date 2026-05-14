# SPDX-FileCopyrightText: SUSE LLC
# SPDX-License-Identifier: Apache-2.0

# Used by "mix format"
[
  inputs: ["{mix,.formatter}.exs", "{config,test}/**/*.{ex,exs}", "lib/*.ex"],
  import_deps: [:protobuf]
]
