// Code generated by protoc-gen-go. DO NOT EDIT.
// versions:
// 	protoc-gen-go v1.28.1
// 	protoc        v3.20.1
// source: protobuf/operator_execution_requested.proto

package events

import (
	protoreflect "google.golang.org/protobuf/reflect/protoreflect"
	protoimpl "google.golang.org/protobuf/runtime/protoimpl"
	structpb "google.golang.org/protobuf/types/known/structpb"
	reflect "reflect"
	sync "sync"
)

const (
	// Verify that this generated code is sufficiently up-to-date.
	_ = protoimpl.EnforceVersion(20 - protoimpl.MinVersion)
	// Verify that runtime/protoimpl is sufficiently up-to-date.
	_ = protoimpl.EnforceVersion(protoimpl.MaxVersion - 20)
)

type OperatorExecutionRequestedTarget struct {
	state         protoimpl.MessageState
	sizeCache     protoimpl.SizeCache
	unknownFields protoimpl.UnknownFields

	AgentId   string                     `protobuf:"bytes,1,opt,name=agent_id,json=agentId,proto3" json:"agent_id,omitempty"`
	Operator  string                     `protobuf:"bytes,2,opt,name=operator,proto3" json:"operator,omitempty"`
	Arguments map[string]*structpb.Value `protobuf:"bytes,3,rep,name=arguments,proto3" json:"arguments,omitempty" protobuf_key:"bytes,1,opt,name=key,proto3" protobuf_val:"bytes,2,opt,name=value,proto3"`
}

func (x *OperatorExecutionRequestedTarget) Reset() {
	*x = OperatorExecutionRequestedTarget{}
	if protoimpl.UnsafeEnabled {
		mi := &file_protobuf_operator_execution_requested_proto_msgTypes[0]
		ms := protoimpl.X.MessageStateOf(protoimpl.Pointer(x))
		ms.StoreMessageInfo(mi)
	}
}

func (x *OperatorExecutionRequestedTarget) String() string {
	return protoimpl.X.MessageStringOf(x)
}

func (*OperatorExecutionRequestedTarget) ProtoMessage() {}

func (x *OperatorExecutionRequestedTarget) ProtoReflect() protoreflect.Message {
	mi := &file_protobuf_operator_execution_requested_proto_msgTypes[0]
	if protoimpl.UnsafeEnabled && x != nil {
		ms := protoimpl.X.MessageStateOf(protoimpl.Pointer(x))
		if ms.LoadMessageInfo() == nil {
			ms.StoreMessageInfo(mi)
		}
		return ms
	}
	return mi.MessageOf(x)
}

// Deprecated: Use OperatorExecutionRequestedTarget.ProtoReflect.Descriptor instead.
func (*OperatorExecutionRequestedTarget) Descriptor() ([]byte, []int) {
	return file_protobuf_operator_execution_requested_proto_rawDescGZIP(), []int{0}
}

func (x *OperatorExecutionRequestedTarget) GetAgentId() string {
	if x != nil {
		return x.AgentId
	}
	return ""
}

func (x *OperatorExecutionRequestedTarget) GetOperator() string {
	if x != nil {
		return x.Operator
	}
	return ""
}

func (x *OperatorExecutionRequestedTarget) GetArguments() map[string]*structpb.Value {
	if x != nil {
		return x.Arguments
	}
	return nil
}

type OperatorExecutionRequested struct {
	state         protoimpl.MessageState
	sizeCache     protoimpl.SizeCache
	unknownFields protoimpl.UnknownFields

	OperationId string                              `protobuf:"bytes,1,opt,name=operation_id,json=operationId,proto3" json:"operation_id,omitempty"`
	GroupId     string                              `protobuf:"bytes,2,opt,name=group_id,json=groupId,proto3" json:"group_id,omitempty"`
	StepNumber  int32                               `protobuf:"varint,3,opt,name=step_number,json=stepNumber,proto3" json:"step_number,omitempty"`
	Targets     []*OperatorExecutionRequestedTarget `protobuf:"bytes,4,rep,name=targets,proto3" json:"targets,omitempty"`
}

func (x *OperatorExecutionRequested) Reset() {
	*x = OperatorExecutionRequested{}
	if protoimpl.UnsafeEnabled {
		mi := &file_protobuf_operator_execution_requested_proto_msgTypes[1]
		ms := protoimpl.X.MessageStateOf(protoimpl.Pointer(x))
		ms.StoreMessageInfo(mi)
	}
}

func (x *OperatorExecutionRequested) String() string {
	return protoimpl.X.MessageStringOf(x)
}

func (*OperatorExecutionRequested) ProtoMessage() {}

func (x *OperatorExecutionRequested) ProtoReflect() protoreflect.Message {
	mi := &file_protobuf_operator_execution_requested_proto_msgTypes[1]
	if protoimpl.UnsafeEnabled && x != nil {
		ms := protoimpl.X.MessageStateOf(protoimpl.Pointer(x))
		if ms.LoadMessageInfo() == nil {
			ms.StoreMessageInfo(mi)
		}
		return ms
	}
	return mi.MessageOf(x)
}

// Deprecated: Use OperatorExecutionRequested.ProtoReflect.Descriptor instead.
func (*OperatorExecutionRequested) Descriptor() ([]byte, []int) {
	return file_protobuf_operator_execution_requested_proto_rawDescGZIP(), []int{1}
}

func (x *OperatorExecutionRequested) GetOperationId() string {
	if x != nil {
		return x.OperationId
	}
	return ""
}

func (x *OperatorExecutionRequested) GetGroupId() string {
	if x != nil {
		return x.GroupId
	}
	return ""
}

func (x *OperatorExecutionRequested) GetStepNumber() int32 {
	if x != nil {
		return x.StepNumber
	}
	return 0
}

func (x *OperatorExecutionRequested) GetTargets() []*OperatorExecutionRequestedTarget {
	if x != nil {
		return x.Targets
	}
	return nil
}

var File_protobuf_operator_execution_requested_proto protoreflect.FileDescriptor

var file_protobuf_operator_execution_requested_proto_rawDesc = []byte{
	0x0a, 0x2b, 0x70, 0x72, 0x6f, 0x74, 0x6f, 0x62, 0x75, 0x66, 0x2f, 0x6f, 0x70, 0x65, 0x72, 0x61,
	0x74, 0x6f, 0x72, 0x5f, 0x65, 0x78, 0x65, 0x63, 0x75, 0x74, 0x69, 0x6f, 0x6e, 0x5f, 0x72, 0x65,
	0x71, 0x75, 0x65, 0x73, 0x74, 0x65, 0x64, 0x2e, 0x70, 0x72, 0x6f, 0x74, 0x6f, 0x12, 0x14, 0x54,
	0x72, 0x65, 0x6e, 0x74, 0x6f, 0x2e, 0x4f, 0x70, 0x65, 0x72, 0x61, 0x74, 0x69, 0x6f, 0x6e, 0x73,
	0x2e, 0x56, 0x31, 0x1a, 0x1c, 0x67, 0x6f, 0x6f, 0x67, 0x6c, 0x65, 0x2f, 0x70, 0x72, 0x6f, 0x74,
	0x6f, 0x62, 0x75, 0x66, 0x2f, 0x73, 0x74, 0x72, 0x75, 0x63, 0x74, 0x2e, 0x70, 0x72, 0x6f, 0x74,
	0x6f, 0x22, 0x94, 0x02, 0x0a, 0x20, 0x4f, 0x70, 0x65, 0x72, 0x61, 0x74, 0x6f, 0x72, 0x45, 0x78,
	0x65, 0x63, 0x75, 0x74, 0x69, 0x6f, 0x6e, 0x52, 0x65, 0x71, 0x75, 0x65, 0x73, 0x74, 0x65, 0x64,
	0x54, 0x61, 0x72, 0x67, 0x65, 0x74, 0x12, 0x19, 0x0a, 0x08, 0x61, 0x67, 0x65, 0x6e, 0x74, 0x5f,
	0x69, 0x64, 0x18, 0x01, 0x20, 0x01, 0x28, 0x09, 0x52, 0x07, 0x61, 0x67, 0x65, 0x6e, 0x74, 0x49,
	0x64, 0x12, 0x1a, 0x0a, 0x08, 0x6f, 0x70, 0x65, 0x72, 0x61, 0x74, 0x6f, 0x72, 0x18, 0x02, 0x20,
	0x01, 0x28, 0x09, 0x52, 0x08, 0x6f, 0x70, 0x65, 0x72, 0x61, 0x74, 0x6f, 0x72, 0x12, 0x63, 0x0a,
	0x09, 0x61, 0x72, 0x67, 0x75, 0x6d, 0x65, 0x6e, 0x74, 0x73, 0x18, 0x03, 0x20, 0x03, 0x28, 0x0b,
	0x32, 0x45, 0x2e, 0x54, 0x72, 0x65, 0x6e, 0x74, 0x6f, 0x2e, 0x4f, 0x70, 0x65, 0x72, 0x61, 0x74,
	0x69, 0x6f, 0x6e, 0x73, 0x2e, 0x56, 0x31, 0x2e, 0x4f, 0x70, 0x65, 0x72, 0x61, 0x74, 0x6f, 0x72,
	0x45, 0x78, 0x65, 0x63, 0x75, 0x74, 0x69, 0x6f, 0x6e, 0x52, 0x65, 0x71, 0x75, 0x65, 0x73, 0x74,
	0x65, 0x64, 0x54, 0x61, 0x72, 0x67, 0x65, 0x74, 0x2e, 0x41, 0x72, 0x67, 0x75, 0x6d, 0x65, 0x6e,
	0x74, 0x73, 0x45, 0x6e, 0x74, 0x72, 0x79, 0x52, 0x09, 0x61, 0x72, 0x67, 0x75, 0x6d, 0x65, 0x6e,
	0x74, 0x73, 0x1a, 0x54, 0x0a, 0x0e, 0x41, 0x72, 0x67, 0x75, 0x6d, 0x65, 0x6e, 0x74, 0x73, 0x45,
	0x6e, 0x74, 0x72, 0x79, 0x12, 0x10, 0x0a, 0x03, 0x6b, 0x65, 0x79, 0x18, 0x01, 0x20, 0x01, 0x28,
	0x09, 0x52, 0x03, 0x6b, 0x65, 0x79, 0x12, 0x2c, 0x0a, 0x05, 0x76, 0x61, 0x6c, 0x75, 0x65, 0x18,
	0x02, 0x20, 0x01, 0x28, 0x0b, 0x32, 0x16, 0x2e, 0x67, 0x6f, 0x6f, 0x67, 0x6c, 0x65, 0x2e, 0x70,
	0x72, 0x6f, 0x74, 0x6f, 0x62, 0x75, 0x66, 0x2e, 0x56, 0x61, 0x6c, 0x75, 0x65, 0x52, 0x05, 0x76,
	0x61, 0x6c, 0x75, 0x65, 0x3a, 0x02, 0x38, 0x01, 0x22, 0xcd, 0x01, 0x0a, 0x1a, 0x4f, 0x70, 0x65,
	0x72, 0x61, 0x74, 0x6f, 0x72, 0x45, 0x78, 0x65, 0x63, 0x75, 0x74, 0x69, 0x6f, 0x6e, 0x52, 0x65,
	0x71, 0x75, 0x65, 0x73, 0x74, 0x65, 0x64, 0x12, 0x21, 0x0a, 0x0c, 0x6f, 0x70, 0x65, 0x72, 0x61,
	0x74, 0x69, 0x6f, 0x6e, 0x5f, 0x69, 0x64, 0x18, 0x01, 0x20, 0x01, 0x28, 0x09, 0x52, 0x0b, 0x6f,
	0x70, 0x65, 0x72, 0x61, 0x74, 0x69, 0x6f, 0x6e, 0x49, 0x64, 0x12, 0x19, 0x0a, 0x08, 0x67, 0x72,
	0x6f, 0x75, 0x70, 0x5f, 0x69, 0x64, 0x18, 0x02, 0x20, 0x01, 0x28, 0x09, 0x52, 0x07, 0x67, 0x72,
	0x6f, 0x75, 0x70, 0x49, 0x64, 0x12, 0x1f, 0x0a, 0x0b, 0x73, 0x74, 0x65, 0x70, 0x5f, 0x6e, 0x75,
	0x6d, 0x62, 0x65, 0x72, 0x18, 0x03, 0x20, 0x01, 0x28, 0x05, 0x52, 0x0a, 0x73, 0x74, 0x65, 0x70,
	0x4e, 0x75, 0x6d, 0x62, 0x65, 0x72, 0x12, 0x50, 0x0a, 0x07, 0x74, 0x61, 0x72, 0x67, 0x65, 0x74,
	0x73, 0x18, 0x04, 0x20, 0x03, 0x28, 0x0b, 0x32, 0x36, 0x2e, 0x54, 0x72, 0x65, 0x6e, 0x74, 0x6f,
	0x2e, 0x4f, 0x70, 0x65, 0x72, 0x61, 0x74, 0x69, 0x6f, 0x6e, 0x73, 0x2e, 0x56, 0x31, 0x2e, 0x4f,
	0x70, 0x65, 0x72, 0x61, 0x74, 0x6f, 0x72, 0x45, 0x78, 0x65, 0x63, 0x75, 0x74, 0x69, 0x6f, 0x6e,
	0x52, 0x65, 0x71, 0x75, 0x65, 0x73, 0x74, 0x65, 0x64, 0x54, 0x61, 0x72, 0x67, 0x65, 0x74, 0x52,
	0x07, 0x74, 0x61, 0x72, 0x67, 0x65, 0x74, 0x73, 0x42, 0x0a, 0x5a, 0x08, 0x2f, 0x3b, 0x65, 0x76,
	0x65, 0x6e, 0x74, 0x73, 0x62, 0x06, 0x70, 0x72, 0x6f, 0x74, 0x6f, 0x33,
}

var (
	file_protobuf_operator_execution_requested_proto_rawDescOnce sync.Once
	file_protobuf_operator_execution_requested_proto_rawDescData = file_protobuf_operator_execution_requested_proto_rawDesc
)

func file_protobuf_operator_execution_requested_proto_rawDescGZIP() []byte {
	file_protobuf_operator_execution_requested_proto_rawDescOnce.Do(func() {
		file_protobuf_operator_execution_requested_proto_rawDescData = protoimpl.X.CompressGZIP(file_protobuf_operator_execution_requested_proto_rawDescData)
	})
	return file_protobuf_operator_execution_requested_proto_rawDescData
}

var file_protobuf_operator_execution_requested_proto_msgTypes = make([]protoimpl.MessageInfo, 3)
var file_protobuf_operator_execution_requested_proto_goTypes = []interface{}{
	(*OperatorExecutionRequestedTarget)(nil), // 0: Trento.Operations.V1.OperatorExecutionRequestedTarget
	(*OperatorExecutionRequested)(nil),       // 1: Trento.Operations.V1.OperatorExecutionRequested
	nil,                                      // 2: Trento.Operations.V1.OperatorExecutionRequestedTarget.ArgumentsEntry
	(*structpb.Value)(nil),                   // 3: google.protobuf.Value
}
var file_protobuf_operator_execution_requested_proto_depIdxs = []int32{
	2, // 0: Trento.Operations.V1.OperatorExecutionRequestedTarget.arguments:type_name -> Trento.Operations.V1.OperatorExecutionRequestedTarget.ArgumentsEntry
	0, // 1: Trento.Operations.V1.OperatorExecutionRequested.targets:type_name -> Trento.Operations.V1.OperatorExecutionRequestedTarget
	3, // 2: Trento.Operations.V1.OperatorExecutionRequestedTarget.ArgumentsEntry.value:type_name -> google.protobuf.Value
	3, // [3:3] is the sub-list for method output_type
	3, // [3:3] is the sub-list for method input_type
	3, // [3:3] is the sub-list for extension type_name
	3, // [3:3] is the sub-list for extension extendee
	0, // [0:3] is the sub-list for field type_name
}

func init() { file_protobuf_operator_execution_requested_proto_init() }
func file_protobuf_operator_execution_requested_proto_init() {
	if File_protobuf_operator_execution_requested_proto != nil {
		return
	}
	if !protoimpl.UnsafeEnabled {
		file_protobuf_operator_execution_requested_proto_msgTypes[0].Exporter = func(v interface{}, i int) interface{} {
			switch v := v.(*OperatorExecutionRequestedTarget); i {
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
		file_protobuf_operator_execution_requested_proto_msgTypes[1].Exporter = func(v interface{}, i int) interface{} {
			switch v := v.(*OperatorExecutionRequested); i {
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
			RawDescriptor: file_protobuf_operator_execution_requested_proto_rawDesc,
			NumEnums:      0,
			NumMessages:   3,
			NumExtensions: 0,
			NumServices:   0,
		},
		GoTypes:           file_protobuf_operator_execution_requested_proto_goTypes,
		DependencyIndexes: file_protobuf_operator_execution_requested_proto_depIdxs,
		MessageInfos:      file_protobuf_operator_execution_requested_proto_msgTypes,
	}.Build()
	File_protobuf_operator_execution_requested_proto = out.File
	file_protobuf_operator_execution_requested_proto_rawDesc = nil
	file_protobuf_operator_execution_requested_proto_goTypes = nil
	file_protobuf_operator_execution_requested_proto_depIdxs = nil
}
