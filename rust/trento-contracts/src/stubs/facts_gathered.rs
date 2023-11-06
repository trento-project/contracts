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

//! Generated file from `protobuf/facts_gathered.proto`

/// Generated files are compatible only with the same version
/// of protobuf runtime.
const _PROTOBUF_VERSION_CHECK: () = ::protobuf::VERSION_3_3_0;

// @@protoc_insertion_point(message:Trento.Checks.V1.FactError)
#[derive(PartialEq,Clone,Default,Debug)]
pub struct FactError {
    // message fields
    // @@protoc_insertion_point(field:Trento.Checks.V1.FactError.message)
    pub message: ::std::string::String,
    // @@protoc_insertion_point(field:Trento.Checks.V1.FactError.type)
    pub type_: ::std::string::String,
    // special fields
    // @@protoc_insertion_point(special_field:Trento.Checks.V1.FactError.special_fields)
    pub special_fields: ::protobuf::SpecialFields,
}

impl<'a> ::std::default::Default for &'a FactError {
    fn default() -> &'a FactError {
        <FactError as ::protobuf::Message>::default_instance()
    }
}

impl FactError {
    pub fn new() -> FactError {
        ::std::default::Default::default()
    }

    fn generated_message_descriptor_data() -> ::protobuf::reflect::GeneratedMessageDescriptorData {
        let mut fields = ::std::vec::Vec::with_capacity(2);
        let mut oneofs = ::std::vec::Vec::with_capacity(0);
        fields.push(::protobuf::reflect::rt::v2::make_simpler_field_accessor::<_, _>(
            "message",
            |m: &FactError| { &m.message },
            |m: &mut FactError| { &mut m.message },
        ));
        fields.push(::protobuf::reflect::rt::v2::make_simpler_field_accessor::<_, _>(
            "type",
            |m: &FactError| { &m.type_ },
            |m: &mut FactError| { &mut m.type_ },
        ));
        ::protobuf::reflect::GeneratedMessageDescriptorData::new_2::<FactError>(
            "FactError",
            fields,
            oneofs,
        )
    }
}

impl ::protobuf::Message for FactError {
    const NAME: &'static str = "FactError";

    fn is_initialized(&self) -> bool {
        true
    }

    fn merge_from(&mut self, is: &mut ::protobuf::CodedInputStream<'_>) -> ::protobuf::Result<()> {
        while let Some(tag) = is.read_raw_tag_or_eof()? {
            match tag {
                10 => {
                    self.message = is.read_string()?;
                },
                18 => {
                    self.type_ = is.read_string()?;
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
        if !self.message.is_empty() {
            my_size += ::protobuf::rt::string_size(1, &self.message);
        }
        if !self.type_.is_empty() {
            my_size += ::protobuf::rt::string_size(2, &self.type_);
        }
        my_size += ::protobuf::rt::unknown_fields_size(self.special_fields.unknown_fields());
        self.special_fields.cached_size().set(my_size as u32);
        my_size
    }

    fn write_to_with_cached_sizes(&self, os: &mut ::protobuf::CodedOutputStream<'_>) -> ::protobuf::Result<()> {
        if !self.message.is_empty() {
            os.write_string(1, &self.message)?;
        }
        if !self.type_.is_empty() {
            os.write_string(2, &self.type_)?;
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

    fn new() -> FactError {
        FactError::new()
    }

    fn clear(&mut self) {
        self.message.clear();
        self.type_.clear();
        self.special_fields.clear();
    }

    fn default_instance() -> &'static FactError {
        static instance: FactError = FactError {
            message: ::std::string::String::new(),
            type_: ::std::string::String::new(),
            special_fields: ::protobuf::SpecialFields::new(),
        };
        &instance
    }
}

impl ::protobuf::MessageFull for FactError {
    fn descriptor() -> ::protobuf::reflect::MessageDescriptor {
        static descriptor: ::protobuf::rt::Lazy<::protobuf::reflect::MessageDescriptor> = ::protobuf::rt::Lazy::new();
        descriptor.get(|| file_descriptor().message_by_package_relative_name("FactError").unwrap()).clone()
    }
}

impl ::std::fmt::Display for FactError {
    fn fmt(&self, f: &mut ::std::fmt::Formatter<'_>) -> ::std::fmt::Result {
        ::protobuf::text_format::fmt(self, f)
    }
}

impl ::protobuf::reflect::ProtobufValue for FactError {
    type RuntimeType = ::protobuf::reflect::rt::RuntimeTypeMessage<Self>;
}

// @@protoc_insertion_point(message:Trento.Checks.V1.Fact)
#[derive(PartialEq,Clone,Default,Debug)]
pub struct Fact {
    // message fields
    // @@protoc_insertion_point(field:Trento.Checks.V1.Fact.check_id)
    pub check_id: ::std::string::String,
    // @@protoc_insertion_point(field:Trento.Checks.V1.Fact.name)
    pub name: ::std::string::String,
    // message oneof groups
    pub fact_value: ::std::option::Option<fact::Fact_value>,
    // special fields
    // @@protoc_insertion_point(special_field:Trento.Checks.V1.Fact.special_fields)
    pub special_fields: ::protobuf::SpecialFields,
}

impl<'a> ::std::default::Default for &'a Fact {
    fn default() -> &'a Fact {
        <Fact as ::protobuf::Message>::default_instance()
    }
}

impl Fact {
    pub fn new() -> Fact {
        ::std::default::Default::default()
    }

    // .google.protobuf.Value value = 3;

    pub fn value(&self) -> &::protobuf::well_known_types::struct_::Value {
        match self.fact_value {
            ::std::option::Option::Some(fact::Fact_value::Value(ref v)) => v,
            _ => <::protobuf::well_known_types::struct_::Value as ::protobuf::Message>::default_instance(),
        }
    }

    pub fn clear_value(&mut self) {
        self.fact_value = ::std::option::Option::None;
    }

    pub fn has_value(&self) -> bool {
        match self.fact_value {
            ::std::option::Option::Some(fact::Fact_value::Value(..)) => true,
            _ => false,
        }
    }

    // Param is passed by value, moved
    pub fn set_value(&mut self, v: ::protobuf::well_known_types::struct_::Value) {
        self.fact_value = ::std::option::Option::Some(fact::Fact_value::Value(v))
    }

    // Mutable pointer to the field.
    pub fn mut_value(&mut self) -> &mut ::protobuf::well_known_types::struct_::Value {
        if let ::std::option::Option::Some(fact::Fact_value::Value(_)) = self.fact_value {
        } else {
            self.fact_value = ::std::option::Option::Some(fact::Fact_value::Value(::protobuf::well_known_types::struct_::Value::new()));
        }
        match self.fact_value {
            ::std::option::Option::Some(fact::Fact_value::Value(ref mut v)) => v,
            _ => panic!(),
        }
    }

    // Take field
    pub fn take_value(&mut self) -> ::protobuf::well_known_types::struct_::Value {
        if self.has_value() {
            match self.fact_value.take() {
                ::std::option::Option::Some(fact::Fact_value::Value(v)) => v,
                _ => panic!(),
            }
        } else {
            ::protobuf::well_known_types::struct_::Value::new()
        }
    }

    // .Trento.Checks.V1.FactError error_value = 4;

    pub fn error_value(&self) -> &FactError {
        match self.fact_value {
            ::std::option::Option::Some(fact::Fact_value::ErrorValue(ref v)) => v,
            _ => <FactError as ::protobuf::Message>::default_instance(),
        }
    }

    pub fn clear_error_value(&mut self) {
        self.fact_value = ::std::option::Option::None;
    }

    pub fn has_error_value(&self) -> bool {
        match self.fact_value {
            ::std::option::Option::Some(fact::Fact_value::ErrorValue(..)) => true,
            _ => false,
        }
    }

    // Param is passed by value, moved
    pub fn set_error_value(&mut self, v: FactError) {
        self.fact_value = ::std::option::Option::Some(fact::Fact_value::ErrorValue(v))
    }

    // Mutable pointer to the field.
    pub fn mut_error_value(&mut self) -> &mut FactError {
        if let ::std::option::Option::Some(fact::Fact_value::ErrorValue(_)) = self.fact_value {
        } else {
            self.fact_value = ::std::option::Option::Some(fact::Fact_value::ErrorValue(FactError::new()));
        }
        match self.fact_value {
            ::std::option::Option::Some(fact::Fact_value::ErrorValue(ref mut v)) => v,
            _ => panic!(),
        }
    }

    // Take field
    pub fn take_error_value(&mut self) -> FactError {
        if self.has_error_value() {
            match self.fact_value.take() {
                ::std::option::Option::Some(fact::Fact_value::ErrorValue(v)) => v,
                _ => panic!(),
            }
        } else {
            FactError::new()
        }
    }

    fn generated_message_descriptor_data() -> ::protobuf::reflect::GeneratedMessageDescriptorData {
        let mut fields = ::std::vec::Vec::with_capacity(4);
        let mut oneofs = ::std::vec::Vec::with_capacity(1);
        fields.push(::protobuf::reflect::rt::v2::make_simpler_field_accessor::<_, _>(
            "check_id",
            |m: &Fact| { &m.check_id },
            |m: &mut Fact| { &mut m.check_id },
        ));
        fields.push(::protobuf::reflect::rt::v2::make_simpler_field_accessor::<_, _>(
            "name",
            |m: &Fact| { &m.name },
            |m: &mut Fact| { &mut m.name },
        ));
        fields.push(::protobuf::reflect::rt::v2::make_oneof_message_has_get_mut_set_accessor::<_, ::protobuf::well_known_types::struct_::Value>(
            "value",
            Fact::has_value,
            Fact::value,
            Fact::mut_value,
            Fact::set_value,
        ));
        fields.push(::protobuf::reflect::rt::v2::make_oneof_message_has_get_mut_set_accessor::<_, FactError>(
            "error_value",
            Fact::has_error_value,
            Fact::error_value,
            Fact::mut_error_value,
            Fact::set_error_value,
        ));
        oneofs.push(fact::Fact_value::generated_oneof_descriptor_data());
        ::protobuf::reflect::GeneratedMessageDescriptorData::new_2::<Fact>(
            "Fact",
            fields,
            oneofs,
        )
    }
}

impl ::protobuf::Message for Fact {
    const NAME: &'static str = "Fact";

    fn is_initialized(&self) -> bool {
        true
    }

    fn merge_from(&mut self, is: &mut ::protobuf::CodedInputStream<'_>) -> ::protobuf::Result<()> {
        while let Some(tag) = is.read_raw_tag_or_eof()? {
            match tag {
                10 => {
                    self.check_id = is.read_string()?;
                },
                18 => {
                    self.name = is.read_string()?;
                },
                26 => {
                    self.fact_value = ::std::option::Option::Some(fact::Fact_value::Value(is.read_message()?));
                },
                34 => {
                    self.fact_value = ::std::option::Option::Some(fact::Fact_value::ErrorValue(is.read_message()?));
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
        if !self.check_id.is_empty() {
            my_size += ::protobuf::rt::string_size(1, &self.check_id);
        }
        if !self.name.is_empty() {
            my_size += ::protobuf::rt::string_size(2, &self.name);
        }
        if let ::std::option::Option::Some(ref v) = self.fact_value {
            match v {
                &fact::Fact_value::Value(ref v) => {
                    let len = v.compute_size();
                    my_size += 1 + ::protobuf::rt::compute_raw_varint64_size(len) + len;
                },
                &fact::Fact_value::ErrorValue(ref v) => {
                    let len = v.compute_size();
                    my_size += 1 + ::protobuf::rt::compute_raw_varint64_size(len) + len;
                },
            };
        }
        my_size += ::protobuf::rt::unknown_fields_size(self.special_fields.unknown_fields());
        self.special_fields.cached_size().set(my_size as u32);
        my_size
    }

    fn write_to_with_cached_sizes(&self, os: &mut ::protobuf::CodedOutputStream<'_>) -> ::protobuf::Result<()> {
        if !self.check_id.is_empty() {
            os.write_string(1, &self.check_id)?;
        }
        if !self.name.is_empty() {
            os.write_string(2, &self.name)?;
        }
        if let ::std::option::Option::Some(ref v) = self.fact_value {
            match v {
                &fact::Fact_value::Value(ref v) => {
                    ::protobuf::rt::write_message_field_with_cached_size(3, v, os)?;
                },
                &fact::Fact_value::ErrorValue(ref v) => {
                    ::protobuf::rt::write_message_field_with_cached_size(4, v, os)?;
                },
            };
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

    fn new() -> Fact {
        Fact::new()
    }

    fn clear(&mut self) {
        self.check_id.clear();
        self.name.clear();
        self.fact_value = ::std::option::Option::None;
        self.fact_value = ::std::option::Option::None;
        self.special_fields.clear();
    }

    fn default_instance() -> &'static Fact {
        static instance: Fact = Fact {
            check_id: ::std::string::String::new(),
            name: ::std::string::String::new(),
            fact_value: ::std::option::Option::None,
            special_fields: ::protobuf::SpecialFields::new(),
        };
        &instance
    }
}

impl ::protobuf::MessageFull for Fact {
    fn descriptor() -> ::protobuf::reflect::MessageDescriptor {
        static descriptor: ::protobuf::rt::Lazy<::protobuf::reflect::MessageDescriptor> = ::protobuf::rt::Lazy::new();
        descriptor.get(|| file_descriptor().message_by_package_relative_name("Fact").unwrap()).clone()
    }
}

impl ::std::fmt::Display for Fact {
    fn fmt(&self, f: &mut ::std::fmt::Formatter<'_>) -> ::std::fmt::Result {
        ::protobuf::text_format::fmt(self, f)
    }
}

impl ::protobuf::reflect::ProtobufValue for Fact {
    type RuntimeType = ::protobuf::reflect::rt::RuntimeTypeMessage<Self>;
}

/// Nested message and enums of message `Fact`
pub mod fact {

    #[derive(Clone,PartialEq,Debug)]
    #[non_exhaustive]
    // @@protoc_insertion_point(oneof:Trento.Checks.V1.Fact.fact_value)
    pub enum Fact_value {
        // @@protoc_insertion_point(oneof_field:Trento.Checks.V1.Fact.value)
        Value(::protobuf::well_known_types::struct_::Value),
        // @@protoc_insertion_point(oneof_field:Trento.Checks.V1.Fact.error_value)
        ErrorValue(super::FactError),
    }

    impl ::protobuf::Oneof for Fact_value {
    }

    impl ::protobuf::OneofFull for Fact_value {
        fn descriptor() -> ::protobuf::reflect::OneofDescriptor {
            static descriptor: ::protobuf::rt::Lazy<::protobuf::reflect::OneofDescriptor> = ::protobuf::rt::Lazy::new();
            descriptor.get(|| <super::Fact as ::protobuf::MessageFull>::descriptor().oneof_by_name("fact_value").unwrap()).clone()
        }
    }

    impl Fact_value {
        pub(in super) fn generated_oneof_descriptor_data() -> ::protobuf::reflect::GeneratedOneofDescriptorData {
            ::protobuf::reflect::GeneratedOneofDescriptorData::new::<Fact_value>("fact_value")
        }
    }
}

// @@protoc_insertion_point(message:Trento.Checks.V1.FactsGathered)
#[derive(PartialEq,Clone,Default,Debug)]
pub struct FactsGathered {
    // message fields
    // @@protoc_insertion_point(field:Trento.Checks.V1.FactsGathered.execution_id)
    pub execution_id: ::std::string::String,
    // @@protoc_insertion_point(field:Trento.Checks.V1.FactsGathered.group_id)
    pub group_id: ::std::string::String,
    // @@protoc_insertion_point(field:Trento.Checks.V1.FactsGathered.agent_id)
    pub agent_id: ::std::string::String,
    // @@protoc_insertion_point(field:Trento.Checks.V1.FactsGathered.facts_gathered)
    pub facts_gathered: ::std::vec::Vec<Fact>,
    // special fields
    // @@protoc_insertion_point(special_field:Trento.Checks.V1.FactsGathered.special_fields)
    pub special_fields: ::protobuf::SpecialFields,
}

impl<'a> ::std::default::Default for &'a FactsGathered {
    fn default() -> &'a FactsGathered {
        <FactsGathered as ::protobuf::Message>::default_instance()
    }
}

impl FactsGathered {
    pub fn new() -> FactsGathered {
        ::std::default::Default::default()
    }

    fn generated_message_descriptor_data() -> ::protobuf::reflect::GeneratedMessageDescriptorData {
        let mut fields = ::std::vec::Vec::with_capacity(4);
        let mut oneofs = ::std::vec::Vec::with_capacity(0);
        fields.push(::protobuf::reflect::rt::v2::make_simpler_field_accessor::<_, _>(
            "execution_id",
            |m: &FactsGathered| { &m.execution_id },
            |m: &mut FactsGathered| { &mut m.execution_id },
        ));
        fields.push(::protobuf::reflect::rt::v2::make_simpler_field_accessor::<_, _>(
            "group_id",
            |m: &FactsGathered| { &m.group_id },
            |m: &mut FactsGathered| { &mut m.group_id },
        ));
        fields.push(::protobuf::reflect::rt::v2::make_simpler_field_accessor::<_, _>(
            "agent_id",
            |m: &FactsGathered| { &m.agent_id },
            |m: &mut FactsGathered| { &mut m.agent_id },
        ));
        fields.push(::protobuf::reflect::rt::v2::make_vec_simpler_accessor::<_, _>(
            "facts_gathered",
            |m: &FactsGathered| { &m.facts_gathered },
            |m: &mut FactsGathered| { &mut m.facts_gathered },
        ));
        ::protobuf::reflect::GeneratedMessageDescriptorData::new_2::<FactsGathered>(
            "FactsGathered",
            fields,
            oneofs,
        )
    }
}

impl ::protobuf::Message for FactsGathered {
    const NAME: &'static str = "FactsGathered";

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
                    self.agent_id = is.read_string()?;
                },
                34 => {
                    self.facts_gathered.push(is.read_message()?);
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
        if !self.agent_id.is_empty() {
            my_size += ::protobuf::rt::string_size(3, &self.agent_id);
        }
        for value in &self.facts_gathered {
            let len = value.compute_size();
            my_size += 1 + ::protobuf::rt::compute_raw_varint64_size(len) + len;
        };
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
        if !self.agent_id.is_empty() {
            os.write_string(3, &self.agent_id)?;
        }
        for v in &self.facts_gathered {
            ::protobuf::rt::write_message_field_with_cached_size(4, v, os)?;
        };
        os.write_unknown_fields(self.special_fields.unknown_fields())?;
        ::std::result::Result::Ok(())
    }

    fn special_fields(&self) -> &::protobuf::SpecialFields {
        &self.special_fields
    }

    fn mut_special_fields(&mut self) -> &mut ::protobuf::SpecialFields {
        &mut self.special_fields
    }

    fn new() -> FactsGathered {
        FactsGathered::new()
    }

    fn clear(&mut self) {
        self.execution_id.clear();
        self.group_id.clear();
        self.agent_id.clear();
        self.facts_gathered.clear();
        self.special_fields.clear();
    }

    fn default_instance() -> &'static FactsGathered {
        static instance: FactsGathered = FactsGathered {
            execution_id: ::std::string::String::new(),
            group_id: ::std::string::String::new(),
            agent_id: ::std::string::String::new(),
            facts_gathered: ::std::vec::Vec::new(),
            special_fields: ::protobuf::SpecialFields::new(),
        };
        &instance
    }
}

impl ::protobuf::MessageFull for FactsGathered {
    fn descriptor() -> ::protobuf::reflect::MessageDescriptor {
        static descriptor: ::protobuf::rt::Lazy<::protobuf::reflect::MessageDescriptor> = ::protobuf::rt::Lazy::new();
        descriptor.get(|| file_descriptor().message_by_package_relative_name("FactsGathered").unwrap()).clone()
    }
}

impl ::std::fmt::Display for FactsGathered {
    fn fmt(&self, f: &mut ::std::fmt::Formatter<'_>) -> ::std::fmt::Result {
        ::protobuf::text_format::fmt(self, f)
    }
}

impl ::protobuf::reflect::ProtobufValue for FactsGathered {
    type RuntimeType = ::protobuf::reflect::rt::RuntimeTypeMessage<Self>;
}

static file_descriptor_proto_data: &'static [u8] = b"\
    \n\x1dprotobuf/facts_gathered.proto\x12\x10Trento.Checks.V1\x1a\x1cgoogl\
    e/protobuf/struct.proto\"9\n\tFactError\x12\x18\n\x07message\x18\x01\x20\
    \x01(\tR\x07message\x12\x12\n\x04type\x18\x02\x20\x01(\tR\x04type\"\xb3\
    \x01\n\x04Fact\x12\x19\n\x08check_id\x18\x01\x20\x01(\tR\x07checkId\x12\
    \x12\n\x04name\x18\x02\x20\x01(\tR\x04name\x12.\n\x05value\x18\x03\x20\
    \x01(\x0b2\x16.google.protobuf.ValueH\0R\x05value\x12>\n\x0berror_value\
    \x18\x04\x20\x01(\x0b2\x1b.Trento.Checks.V1.FactErrorH\0R\nerrorValueB\
    \x0c\n\nfact_value\"\xa7\x01\n\rFactsGathered\x12!\n\x0cexecution_id\x18\
    \x01\x20\x01(\tR\x0bexecutionId\x12\x19\n\x08group_id\x18\x02\x20\x01(\t\
    R\x07groupId\x12\x19\n\x08agent_id\x18\x03\x20\x01(\tR\x07agentId\x12=\n\
    \x0efacts_gathered\x18\x04\x20\x03(\x0b2\x16.Trento.Checks.V1.FactR\rfac\
    tsGatheredB\nZ\x08/;eventsJ\xd4\x05\n\x06\x12\x04\0\0\x1c\x01\n\x08\n\
    \x01\x0c\x12\x03\0\0\x12\n\x08\n\x01\x02\x12\x03\x02\0\x19\n\x08\n\x01\
    \x08\x12\x03\x03\0\x1f\n\t\n\x02\x08\x0b\x12\x03\x03\0\x1f\n\t\n\x02\x03\
    \0\x12\x03\x05\0&\n\n\n\x02\x04\0\x12\x04\x07\0\n\x01\n\n\n\x03\x04\0\
    \x01\x12\x03\x07\x08\x11\n\x0b\n\x04\x04\0\x02\0\x12\x03\x08\x02\x15\n\
    \x0c\n\x05\x04\0\x02\0\x05\x12\x03\x08\x02\x08\n\x0c\n\x05\x04\0\x02\0\
    \x01\x12\x03\x08\t\x10\n\x0c\n\x05\x04\0\x02\0\x03\x12\x03\x08\x13\x14\n\
    \x0b\n\x04\x04\0\x02\x01\x12\x03\t\x02\x12\n\x0c\n\x05\x04\0\x02\x01\x05\
    \x12\x03\t\x02\x08\n\x0c\n\x05\x04\0\x02\x01\x01\x12\x03\t\t\r\n\x0c\n\
    \x05\x04\0\x02\x01\x03\x12\x03\t\x10\x11\n\n\n\x02\x04\x01\x12\x04\x0c\0\
    \x14\x01\n\n\n\x03\x04\x01\x01\x12\x03\x0c\x08\x0c\n\x0b\n\x04\x04\x01\
    \x02\0\x12\x03\r\x02\x16\n\x0c\n\x05\x04\x01\x02\0\x05\x12\x03\r\x02\x08\
    \n\x0c\n\x05\x04\x01\x02\0\x01\x12\x03\r\t\x11\n\x0c\n\x05\x04\x01\x02\0\
    \x03\x12\x03\r\x14\x15\n\x0b\n\x04\x04\x01\x02\x01\x12\x03\x0e\x02\x12\n\
    \x0c\n\x05\x04\x01\x02\x01\x05\x12\x03\x0e\x02\x08\n\x0c\n\x05\x04\x01\
    \x02\x01\x01\x12\x03\x0e\t\r\n\x0c\n\x05\x04\x01\x02\x01\x03\x12\x03\x0e\
    \x10\x11\n\x0c\n\x04\x04\x01\x08\0\x12\x04\x0f\x02\x13\x03\n\x0c\n\x05\
    \x04\x01\x08\0\x01\x12\x03\x0f\x08\x12\n\x0b\n\x04\x04\x01\x02\x02\x12\
    \x03\x10\x04$\n\x0c\n\x05\x04\x01\x02\x02\x06\x12\x03\x10\x04\x19\n\x0c\
    \n\x05\x04\x01\x02\x02\x01\x12\x03\x10\x1a\x1f\n\x0c\n\x05\x04\x01\x02\
    \x02\x03\x12\x03\x10\"#\n\x0b\n\x04\x04\x01\x02\x03\x12\x03\x12\x04\x1e\
    \n\x0c\n\x05\x04\x01\x02\x03\x06\x12\x03\x12\x04\r\n\x0c\n\x05\x04\x01\
    \x02\x03\x01\x12\x03\x12\x0e\x19\n\x0c\n\x05\x04\x01\x02\x03\x03\x12\x03\
    \x12\x1c\x1d\n\n\n\x02\x04\x02\x12\x04\x16\0\x1c\x01\n\n\n\x03\x04\x02\
    \x01\x12\x03\x16\x08\x15\n\x0b\n\x04\x04\x02\x02\0\x12\x03\x17\x02\x1a\n\
    \x0c\n\x05\x04\x02\x02\0\x05\x12\x03\x17\x02\x08\n\x0c\n\x05\x04\x02\x02\
    \0\x01\x12\x03\x17\t\x15\n\x0c\n\x05\x04\x02\x02\0\x03\x12\x03\x17\x18\
    \x19\n\x0b\n\x04\x04\x02\x02\x01\x12\x03\x18\x02\x16\n\x0c\n\x05\x04\x02\
    \x02\x01\x05\x12\x03\x18\x02\x08\n\x0c\n\x05\x04\x02\x02\x01\x01\x12\x03\
    \x18\t\x11\n\x0c\n\x05\x04\x02\x02\x01\x03\x12\x03\x18\x14\x15\n\x0b\n\
    \x04\x04\x02\x02\x02\x12\x03\x19\x02\x16\n\x0c\n\x05\x04\x02\x02\x02\x05\
    \x12\x03\x19\x02\x08\n\x0c\n\x05\x04\x02\x02\x02\x01\x12\x03\x19\t\x11\n\
    \x0c\n\x05\x04\x02\x02\x02\x03\x12\x03\x19\x14\x15\n\x0b\n\x04\x04\x02\
    \x02\x03\x12\x03\x1b\x02#\n\x0c\n\x05\x04\x02\x02\x03\x04\x12\x03\x1b\
    \x02\n\n\x0c\n\x05\x04\x02\x02\x03\x06\x12\x03\x1b\x0b\x0f\n\x0c\n\x05\
    \x04\x02\x02\x03\x01\x12\x03\x1b\x10\x1e\n\x0c\n\x05\x04\x02\x02\x03\x03\
    \x12\x03\x1b!\"b\x06proto3\
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
            let mut deps = ::std::vec::Vec::with_capacity(1);
            deps.push(::protobuf::well_known_types::struct_::file_descriptor().clone());
            let mut messages = ::std::vec::Vec::with_capacity(3);
            messages.push(FactError::generated_message_descriptor_data());
            messages.push(Fact::generated_message_descriptor_data());
            messages.push(FactsGathered::generated_message_descriptor_data());
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