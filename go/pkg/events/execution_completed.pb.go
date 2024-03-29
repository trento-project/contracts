// Code generated by protoc-gen-go. DO NOT EDIT.
// versions:
// 	protoc-gen-go v1.28.1
// 	protoc        v3.20.1
// source: protobuf/execution_completed.proto

package events

import (
	protoreflect "google.golang.org/protobuf/reflect/protoreflect"
	protoimpl "google.golang.org/protobuf/runtime/protoimpl"
	reflect "reflect"
	sync "sync"
)

const (
	// Verify that this generated code is sufficiently up-to-date.
	_ = protoimpl.EnforceVersion(20 - protoimpl.MinVersion)
	// Verify that runtime/protoimpl is sufficiently up-to-date.
	_ = protoimpl.EnforceVersion(protoimpl.MaxVersion - 20)
)

type Result int32

const (
	Result_PASSING  Result = 0
	Result_WARNING  Result = 1
	Result_CRITICAL Result = 2
)

// Enum value maps for Result.
var (
	Result_name = map[int32]string{
		0: "PASSING",
		1: "WARNING",
		2: "CRITICAL",
	}
	Result_value = map[string]int32{
		"PASSING":  0,
		"WARNING":  1,
		"CRITICAL": 2,
	}
)

func (x Result) Enum() *Result {
	p := new(Result)
	*p = x
	return p
}

func (x Result) String() string {
	return protoimpl.X.EnumStringOf(x.Descriptor(), protoreflect.EnumNumber(x))
}

func (Result) Descriptor() protoreflect.EnumDescriptor {
	return file_protobuf_execution_completed_proto_enumTypes[0].Descriptor()
}

func (Result) Type() protoreflect.EnumType {
	return &file_protobuf_execution_completed_proto_enumTypes[0]
}

func (x Result) Number() protoreflect.EnumNumber {
	return protoreflect.EnumNumber(x)
}

// Deprecated: Use Result.Descriptor instead.
func (Result) EnumDescriptor() ([]byte, []int) {
	return file_protobuf_execution_completed_proto_rawDescGZIP(), []int{0}
}

type ExecutionCompleted struct {
	state         protoimpl.MessageState
	sizeCache     protoimpl.SizeCache
	unknownFields protoimpl.UnknownFields

	ExecutionId string `protobuf:"bytes,1,opt,name=execution_id,json=executionId,proto3" json:"execution_id,omitempty"`
	GroupId     string `protobuf:"bytes,2,opt,name=group_id,json=groupId,proto3" json:"group_id,omitempty"`
	Result      Result `protobuf:"varint,3,opt,name=result,proto3,enum=Trento.Checks.V1.Result" json:"result,omitempty"`
	TargetType  string `protobuf:"bytes,4,opt,name=target_type,json=targetType,proto3" json:"target_type,omitempty"`
}

func (x *ExecutionCompleted) Reset() {
	*x = ExecutionCompleted{}
	if protoimpl.UnsafeEnabled {
		mi := &file_protobuf_execution_completed_proto_msgTypes[0]
		ms := protoimpl.X.MessageStateOf(protoimpl.Pointer(x))
		ms.StoreMessageInfo(mi)
	}
}

func (x *ExecutionCompleted) String() string {
	return protoimpl.X.MessageStringOf(x)
}

func (*ExecutionCompleted) ProtoMessage() {}

func (x *ExecutionCompleted) ProtoReflect() protoreflect.Message {
	mi := &file_protobuf_execution_completed_proto_msgTypes[0]
	if protoimpl.UnsafeEnabled && x != nil {
		ms := protoimpl.X.MessageStateOf(protoimpl.Pointer(x))
		if ms.LoadMessageInfo() == nil {
			ms.StoreMessageInfo(mi)
		}
		return ms
	}
	return mi.MessageOf(x)
}

// Deprecated: Use ExecutionCompleted.ProtoReflect.Descriptor instead.
func (*ExecutionCompleted) Descriptor() ([]byte, []int) {
	return file_protobuf_execution_completed_proto_rawDescGZIP(), []int{0}
}

func (x *ExecutionCompleted) GetExecutionId() string {
	if x != nil {
		return x.ExecutionId
	}
	return ""
}

func (x *ExecutionCompleted) GetGroupId() string {
	if x != nil {
		return x.GroupId
	}
	return ""
}

func (x *ExecutionCompleted) GetResult() Result {
	if x != nil {
		return x.Result
	}
	return Result_PASSING
}

func (x *ExecutionCompleted) GetTargetType() string {
	if x != nil {
		return x.TargetType
	}
	return ""
}

var File_protobuf_execution_completed_proto protoreflect.FileDescriptor

var file_protobuf_execution_completed_proto_rawDesc = []byte{
	0x0a, 0x22, 0x70, 0x72, 0x6f, 0x74, 0x6f, 0x62, 0x75, 0x66, 0x2f, 0x65, 0x78, 0x65, 0x63, 0x75,
	0x74, 0x69, 0x6f, 0x6e, 0x5f, 0x63, 0x6f, 0x6d, 0x70, 0x6c, 0x65, 0x74, 0x65, 0x64, 0x2e, 0x70,
	0x72, 0x6f, 0x74, 0x6f, 0x12, 0x10, 0x54, 0x72, 0x65, 0x6e, 0x74, 0x6f, 0x2e, 0x43, 0x68, 0x65,
	0x63, 0x6b, 0x73, 0x2e, 0x56, 0x31, 0x22, 0xa5, 0x01, 0x0a, 0x12, 0x45, 0x78, 0x65, 0x63, 0x75,
	0x74, 0x69, 0x6f, 0x6e, 0x43, 0x6f, 0x6d, 0x70, 0x6c, 0x65, 0x74, 0x65, 0x64, 0x12, 0x21, 0x0a,
	0x0c, 0x65, 0x78, 0x65, 0x63, 0x75, 0x74, 0x69, 0x6f, 0x6e, 0x5f, 0x69, 0x64, 0x18, 0x01, 0x20,
	0x01, 0x28, 0x09, 0x52, 0x0b, 0x65, 0x78, 0x65, 0x63, 0x75, 0x74, 0x69, 0x6f, 0x6e, 0x49, 0x64,
	0x12, 0x19, 0x0a, 0x08, 0x67, 0x72, 0x6f, 0x75, 0x70, 0x5f, 0x69, 0x64, 0x18, 0x02, 0x20, 0x01,
	0x28, 0x09, 0x52, 0x07, 0x67, 0x72, 0x6f, 0x75, 0x70, 0x49, 0x64, 0x12, 0x30, 0x0a, 0x06, 0x72,
	0x65, 0x73, 0x75, 0x6c, 0x74, 0x18, 0x03, 0x20, 0x01, 0x28, 0x0e, 0x32, 0x18, 0x2e, 0x54, 0x72,
	0x65, 0x6e, 0x74, 0x6f, 0x2e, 0x43, 0x68, 0x65, 0x63, 0x6b, 0x73, 0x2e, 0x56, 0x31, 0x2e, 0x52,
	0x65, 0x73, 0x75, 0x6c, 0x74, 0x52, 0x06, 0x72, 0x65, 0x73, 0x75, 0x6c, 0x74, 0x12, 0x1f, 0x0a,
	0x0b, 0x74, 0x61, 0x72, 0x67, 0x65, 0x74, 0x5f, 0x74, 0x79, 0x70, 0x65, 0x18, 0x04, 0x20, 0x01,
	0x28, 0x09, 0x52, 0x0a, 0x74, 0x61, 0x72, 0x67, 0x65, 0x74, 0x54, 0x79, 0x70, 0x65, 0x2a, 0x30,
	0x0a, 0x06, 0x52, 0x65, 0x73, 0x75, 0x6c, 0x74, 0x12, 0x0b, 0x0a, 0x07, 0x50, 0x41, 0x53, 0x53,
	0x49, 0x4e, 0x47, 0x10, 0x00, 0x12, 0x0b, 0x0a, 0x07, 0x57, 0x41, 0x52, 0x4e, 0x49, 0x4e, 0x47,
	0x10, 0x01, 0x12, 0x0c, 0x0a, 0x08, 0x43, 0x52, 0x49, 0x54, 0x49, 0x43, 0x41, 0x4c, 0x10, 0x02,
	0x42, 0x0a, 0x5a, 0x08, 0x2f, 0x3b, 0x65, 0x76, 0x65, 0x6e, 0x74, 0x73, 0x62, 0x06, 0x70, 0x72,
	0x6f, 0x74, 0x6f, 0x33,
}

var (
	file_protobuf_execution_completed_proto_rawDescOnce sync.Once
	file_protobuf_execution_completed_proto_rawDescData = file_protobuf_execution_completed_proto_rawDesc
)

func file_protobuf_execution_completed_proto_rawDescGZIP() []byte {
	file_protobuf_execution_completed_proto_rawDescOnce.Do(func() {
		file_protobuf_execution_completed_proto_rawDescData = protoimpl.X.CompressGZIP(file_protobuf_execution_completed_proto_rawDescData)
	})
	return file_protobuf_execution_completed_proto_rawDescData
}

var file_protobuf_execution_completed_proto_enumTypes = make([]protoimpl.EnumInfo, 1)
var file_protobuf_execution_completed_proto_msgTypes = make([]protoimpl.MessageInfo, 1)
var file_protobuf_execution_completed_proto_goTypes = []interface{}{
	(Result)(0),                // 0: Trento.Checks.V1.Result
	(*ExecutionCompleted)(nil), // 1: Trento.Checks.V1.ExecutionCompleted
}
var file_protobuf_execution_completed_proto_depIdxs = []int32{
	0, // 0: Trento.Checks.V1.ExecutionCompleted.result:type_name -> Trento.Checks.V1.Result
	1, // [1:1] is the sub-list for method output_type
	1, // [1:1] is the sub-list for method input_type
	1, // [1:1] is the sub-list for extension type_name
	1, // [1:1] is the sub-list for extension extendee
	0, // [0:1] is the sub-list for field type_name
}

func init() { file_protobuf_execution_completed_proto_init() }
func file_protobuf_execution_completed_proto_init() {
	if File_protobuf_execution_completed_proto != nil {
		return
	}
	if !protoimpl.UnsafeEnabled {
		file_protobuf_execution_completed_proto_msgTypes[0].Exporter = func(v interface{}, i int) interface{} {
			switch v := v.(*ExecutionCompleted); i {
			case 0:
				return &v.state
			case 1:
				return &v.sizeCache
			case 2:
				return &v.unknownFields
			default:
				return nil
			}
		}
	}
	type x struct{}
	out := protoimpl.TypeBuilder{
		File: protoimpl.DescBuilder{
			GoPackagePath: reflect.TypeOf(x{}).PkgPath(),
			RawDescriptor: file_protobuf_execution_completed_proto_rawDesc,
			NumEnums:      1,
			NumMessages:   1,
			NumExtensions: 0,
			NumServices:   0,
		},
		GoTypes:           file_protobuf_execution_completed_proto_goTypes,
		DependencyIndexes: file_protobuf_execution_completed_proto_depIdxs,
		EnumInfos:         file_protobuf_execution_completed_proto_enumTypes,
		MessageInfos:      file_protobuf_execution_completed_proto_msgTypes,
	}.Build()
	File_protobuf_execution_completed_proto = out.File
	file_protobuf_execution_completed_proto_rawDesc = nil
	file_protobuf_execution_completed_proto_goTypes = nil
	file_protobuf_execution_completed_proto_depIdxs = nil
}
