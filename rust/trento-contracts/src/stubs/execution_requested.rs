// This file is generated by rust-protobuf 3.3.0. Do not edit
// .proto file is parsed by protoc --rust-out=...
// @generated

// https://github.com/rust-lang/rust-clippy/issues/702
#![allow(unknown_lints)]
#![allow(clippy::all)]

#![allow(unused_attributes)]
#![cfg_attr(rustfmt, rustfmt::skip)]

#![allow(box_pointers)]
#![allow(dead_code)]
#![allow(missing_docs)]
#![allow(non_camel_case_types)]
#![allow(non_snake_case)]
#![allow(non_upper_case_globals)]
#![allow(trivial_casts)]
#![allow(unused_results)]
#![allow(unused_mut)]

//! Generated file from `protobuf/execution_requested.proto`

/// Generated files are compatible only with the same version
/// of protobuf runtime.
const _PROTOBUF_VERSION_CHECK: () = ::protobuf::VERSION_3_3_0;

// @@protoc_insertion_point(message:Trento.Checks.V1.ExecutionRequested)
#[derive(PartialEq,Clone,Default,Debug)]
pub struct ExecutionRequested {
    // message fields
    // @@protoc_insertion_point(field:Trento.Checks.V1.ExecutionRequested.execution_id)
    pub execution_id: ::std::string::String,
    // @@protoc_insertion_point(field:Trento.Checks.V1.ExecutionRequested.group_id)
    pub group_id: ::std::string::String,
    // @@protoc_insertion_point(field:Trento.Checks.V1.ExecutionRequested.targets)
    pub targets: ::std::vec::Vec<super::target::Target>,
    // @@protoc_insertion_point(field:Trento.Checks.V1.ExecutionRequested.env)
    pub env: ::std::collections::HashMap<::std::string::String, ::protobuf::well_known_types::struct_::Value>,
    // @@protoc_insertion_point(field:Trento.Checks.V1.ExecutionRequested.target_type)
    pub target_type: ::std::string::String,
    // special fields
    // @@protoc_insertion_point(special_field:Trento.Checks.V1.ExecutionRequested.special_fields)
    pub special_fields: ::protobuf::SpecialFields,
}

impl<'a> ::std::default::Default for &'a ExecutionRequested {
    fn default() -> &'a ExecutionRequested {
        <ExecutionRequested as ::protobuf::Message>::default_instance()
    }
}

impl ExecutionRequested {
    pub fn new() -> ExecutionRequested {
        ::std::default::Default::default()
    }

    fn generated_message_descriptor_data() -> ::protobuf::reflect::GeneratedMessageDescriptorData {
        let mut fields = ::std::vec::Vec::with_capacity(5);
        let mut oneofs = ::std::vec::Vec::with_capacity(0);
        fields.push(::protobuf::reflect::rt::v2::make_simpler_field_accessor::<_, _>(
            "execution_id",
            |m: &ExecutionRequested| { &m.execution_id },
            |m: &mut ExecutionRequested| { &mut m.execution_id },
        ));
        fields.push(::protobuf::reflect::rt::v2::make_simpler_field_accessor::<_, _>(
            "group_id",
            |m: &ExecutionRequested| { &m.group_id },
            |m: &mut ExecutionRequested| { &mut m.group_id },
        ));
        fields.push(::protobuf::reflect::rt::v2::make_vec_simpler_accessor::<_, _>(
            "targets",
            |m: &ExecutionRequested| { &m.targets },
            |m: &mut ExecutionRequested| { &mut m.targets },
        ));
        fields.push(::protobuf::reflect::rt::v2::make_map_simpler_accessor::<_, _, _>(
            "env",
            |m: &ExecutionRequested| { &m.env },
            |m: &mut ExecutionRequested| { &mut m.env },
        ));
        fields.push(::protobuf::reflect::rt::v2::make_simpler_field_accessor::<_, _>(
            "target_type",
            |m: &ExecutionRequested| { &m.target_type },
            |m: &mut ExecutionRequested| { &mut m.target_type },
        ));
        ::protobuf::reflect::GeneratedMessageDescriptorData::new_2::<ExecutionRequested>(
            "ExecutionRequested",
            fields,
            oneofs,
        )
    }
}

impl ::protobuf::Message for ExecutionRequested {
    const NAME: &'static str = "ExecutionRequested";

    fn is_initialized(&self) -> bool {
        true
    }

    fn merge_from(&mut self, is: &mut ::protobuf::CodedInputStream<'_>) -> ::protobuf::Result<()> {
        while let Some(tag) = is.read_raw_tag_or_eof()? {
            match tag {
                10 => {
                    self.execution_id = is.read_string()?;
                },
                18 => {
                    self.group_id = is.read_string()?;
                },
                26 => {
                    self.targets.push(is.read_message()?);
                },
                34 => {
                    let len = is.read_raw_varint32()?;
                    let old_limit = is.push_limit(len as u64)?;
                    let mut key = ::std::default::Default::default();
                    let mut value = ::std::default::Default::default();
                    while let Some(tag) = is.read_raw_tag_or_eof()? {
                        match tag {
                            10 => key = is.read_string()?,
                            18 => value = is.read_message()?,
                            _ => ::protobuf::rt::skip_field_for_tag(tag, is)?,
                        };
                    }
                    is.pop_limit(old_limit);
                    self.env.insert(key, value);
                },
                42 => {
                    self.target_type = is.read_string()?;
                },
                tag => {
                    ::protobuf::rt::read_unknown_or_skip_group(tag, is, self.special_fields.mut_unknown_fields())?;
                },
            };
        }
        ::std::result::Result::Ok(())
    }

    // Compute sizes of nested messages
    #[allow(unused_variables)]
    fn compute_size(&self) -> u64 {
        let mut my_size = 0;
        if !self.execution_id.is_empty() {
            my_size += ::protobuf::rt::string_size(1, &self.execution_id);
        }
        if !self.group_id.is_empty() {
            my_size += ::protobuf::rt::string_size(2, &self.group_id);
        }
        for value in &self.targets {
            let len = value.compute_size();
            my_size += 1 + ::protobuf::rt::compute_raw_varint64_size(len) + len;
        };
        for (k, v) in &self.env {
            let mut entry_size = 0;
            entry_size += ::protobuf::rt::string_size(1, &k);
            let len = v.compute_size();
            entry_size += 1 + ::protobuf::rt::compute_raw_varint64_size(len) + len;
            my_size += 1 + ::protobuf::rt::compute_raw_varint64_size(entry_size) + entry_size
        };
        if !self.target_type.is_empty() {
            my_size += ::protobuf::rt::string_size(5, &self.target_type);
        }
        my_size += ::protobuf::rt::unknown_fields_size(self.special_fields.unknown_fields());
        self.special_fields.cached_size().set(my_size as u32);
        my_size
    }

    fn write_to_with_cached_sizes(&self, os: &mut ::protobuf::CodedOutputStream<'_>) -> ::protobuf::Result<()> {
        if !self.execution_id.is_empty() {
            os.write_string(1, &self.execution_id)?;
        }
        if !self.group_id.is_empty() {
            os.write_string(2, &self.group_id)?;
        }
        for v in &self.targets {
            ::protobuf::rt::write_message_field_with_cached_size(3, v, os)?;
        };
        for (k, v) in &self.env {
            let mut entry_size = 0;
            entry_size += ::protobuf::rt::string_size(1, &k);
            let len = v.cached_size() as u64;
            entry_size += 1 + ::protobuf::rt::compute_raw_varint64_size(len) + len;
            os.write_raw_varint32(34)?; // Tag.
            os.write_raw_varint32(entry_size as u32)?;
            os.write_string(1, &k)?;
            ::protobuf::rt::write_message_field_with_cached_size(2, v, os)?;
        };
        if !self.target_type.is_empty() {
            os.write_string(5, &self.target_type)?;
        }
        os.write_unknown_fields(self.special_fields.unknown_fields())?;
        ::std::result::Result::Ok(())
    }

    fn special_fields(&self) -> &::protobuf::SpecialFields {
        &self.special_fields
    }

    fn mut_special_fields(&mut self) -> &mut ::protobuf::SpecialFields {
        &mut self.special_fields
    }

    fn new() -> ExecutionRequested {
        ExecutionRequested::new()
    }

    fn clear(&mut self) {
        self.execution_id.clear();
        self.group_id.clear();
        self.targets.clear();
        self.env.clear();
        self.target_type.clear();
        self.special_fields.clear();
    }

    fn default_instance() -> &'static ExecutionRequested {
        static instance: ::protobuf::rt::Lazy<ExecutionRequested> = ::protobuf::rt::Lazy::new();
        instance.get(ExecutionRequested::new)
    }
}

impl ::protobuf::MessageFull for ExecutionRequested {
    fn descriptor() -> ::protobuf::reflect::MessageDescriptor {
        static descriptor: ::protobuf::rt::Lazy<::protobuf::reflect::MessageDescriptor> = ::protobuf::rt::Lazy::new();
        descriptor.get(|| file_descriptor().message_by_package_relative_name("ExecutionRequested").unwrap()).clone()
    }
}

impl ::std::fmt::Display for ExecutionRequested {
    fn fmt(&self, f: &mut ::std::fmt::Formatter<'_>) -> ::std::fmt::Result {
        ::protobuf::text_format::fmt(self, f)
    }
}

impl ::protobuf::reflect::ProtobufValue for ExecutionRequested {
    type RuntimeType = ::protobuf::reflect::rt::RuntimeTypeMessage<Self>;
}

static file_descriptor_proto_data: &'static [u8] = b"\
    \n\"protobuf/execution_requested.proto\x12\x10Trento.Checks.V1\x1a\x1cgo\
    ogle/protobuf/struct.proto\x1a\x15protobuf/target.proto\"\xb8\x02\n\x12E\
    xecutionRequested\x12!\n\x0cexecution_id\x18\x01\x20\x01(\tR\x0bexecutio\
    nId\x12\x19\n\x08group_id\x18\x02\x20\x01(\tR\x07groupId\x122\n\x07targe\
    ts\x18\x03\x20\x03(\x0b2\x18.Trento.Checks.V1.TargetR\x07targets\x12?\n\
    \x03env\x18\x04\x20\x03(\x0b2-.Trento.Checks.V1.ExecutionRequested.EnvEn\
    tryR\x03env\x12\x1f\n\x0btarget_type\x18\x05\x20\x01(\tR\ntargetType\x1a\
    N\n\x08EnvEntry\x12\x10\n\x03key\x18\x01\x20\x01(\tR\x03key\x12,\n\x05va\
    lue\x18\x02\x20\x01(\x0b2\x16.google.protobuf.ValueR\x05value:\x028\x01B\
    \nZ\x08/;eventsJ\x80\x03\n\x06\x12\x04\0\0\x0f\x01\n\x08\n\x01\x0c\x12\
    \x03\0\0\x12\n\x08\n\x01\x02\x12\x03\x02\0\x19\n\x08\n\x01\x08\x12\x03\
    \x03\0\x1f\n\t\n\x02\x08\x0b\x12\x03\x03\0\x1f\n\t\n\x02\x03\0\x12\x03\
    \x05\0&\n\t\n\x02\x03\x01\x12\x03\x06\0\x1f\n\n\n\x02\x04\0\x12\x04\t\0\
    \x0f\x01\n\n\n\x03\x04\0\x01\x12\x03\t\x08\x1a\n\x0b\n\x04\x04\0\x02\0\
    \x12\x03\n\x04\x1c\n\x0c\n\x05\x04\0\x02\0\x05\x12\x03\n\x04\n\n\x0c\n\
    \x05\x04\0\x02\0\x01\x12\x03\n\x0b\x17\n\x0c\n\x05\x04\0\x02\0\x03\x12\
    \x03\n\x1a\x1b\n\x0b\n\x04\x04\0\x02\x01\x12\x03\x0b\x04\x18\n\x0c\n\x05\
    \x04\0\x02\x01\x05\x12\x03\x0b\x04\n\n\x0c\n\x05\x04\0\x02\x01\x01\x12\
    \x03\x0b\x0b\x13\n\x0c\n\x05\x04\0\x02\x01\x03\x12\x03\x0b\x16\x17\n\x0b\
    \n\x04\x04\0\x02\x02\x12\x03\x0c\x04\x20\n\x0c\n\x05\x04\0\x02\x02\x04\
    \x12\x03\x0c\x04\x0c\n\x0c\n\x05\x04\0\x02\x02\x06\x12\x03\x0c\r\x13\n\
    \x0c\n\x05\x04\0\x02\x02\x01\x12\x03\x0c\x14\x1b\n\x0c\n\x05\x04\0\x02\
    \x02\x03\x12\x03\x0c\x1e\x1f\n\x0b\n\x04\x04\0\x02\x03\x12\x03\r\x04/\n\
    \x0c\n\x05\x04\0\x02\x03\x06\x12\x03\r\x04&\n\x0c\n\x05\x04\0\x02\x03\
    \x01\x12\x03\r'*\n\x0c\n\x05\x04\0\x02\x03\x03\x12\x03\r-.\n\x0b\n\x04\
    \x04\0\x02\x04\x12\x03\x0e\x04\x1b\n\x0c\n\x05\x04\0\x02\x04\x05\x12\x03\
    \x0e\x04\n\n\x0c\n\x05\x04\0\x02\x04\x01\x12\x03\x0e\x0b\x16\n\x0c\n\x05\
    \x04\0\x02\x04\x03\x12\x03\x0e\x19\x1ab\x06proto3\
";

/// `FileDescriptorProto` object which was a source for this generated file
fn file_descriptor_proto() -> &'static ::protobuf::descriptor::FileDescriptorProto {
    static file_descriptor_proto_lazy: ::protobuf::rt::Lazy<::protobuf::descriptor::FileDescriptorProto> = ::protobuf::rt::Lazy::new();
    file_descriptor_proto_lazy.get(|| {
        ::protobuf::Message::parse_from_bytes(file_descriptor_proto_data).unwrap()
    })
}

/// `FileDescriptor` object which allows dynamic access to files
pub fn file_descriptor() -> &'static ::protobuf::reflect::FileDescriptor {
    static generated_file_descriptor_lazy: ::protobuf::rt::Lazy<::protobuf::reflect::GeneratedFileDescriptor> = ::protobuf::rt::Lazy::new();
    static file_descriptor: ::protobuf::rt::Lazy<::protobuf::reflect::FileDescriptor> = ::protobuf::rt::Lazy::new();
    file_descriptor.get(|| {
        let generated_file_descriptor = generated_file_descriptor_lazy.get(|| {
            let mut deps = ::std::vec::Vec::with_capacity(2);
            deps.push(::protobuf::well_known_types::struct_::file_descriptor().clone());
            deps.push(super::target::file_descriptor().clone());
            let mut messages = ::std::vec::Vec::with_capacity(1);
            messages.push(ExecutionRequested::generated_message_descriptor_data());
            let mut enums = ::std::vec::Vec::with_capacity(0);
            ::protobuf::reflect::GeneratedFileDescriptor::new_generated(
                file_descriptor_proto(),
                deps,
                messages,
                enums,
            )
        });
        ::protobuf::reflect::FileDescriptor::new_generated_2(generated_file_descriptor)
    })
}
