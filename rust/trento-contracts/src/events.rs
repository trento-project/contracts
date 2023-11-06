use chrono::{DateTime, Utc};
use protobuf::well_known_types::{any::Any, timestamp::Timestamp};
use protobuf::{Message, MessageDyn};
use uuid::Uuid;

use crate::stubs::cloudevent::{CloudEvent, CloudEventAttributeValue};

pub struct EventBuilder {
    id: String,
    source: String,
    timestamp: DateTime<Utc>,
}

impl EventBuilder {
    pub fn new() -> EventBuilder {
        EventBuilder {
            id: Uuid::new_v4().to_string(),
            source: "https://github.com/trento-project".to_owned(),
            timestamp: Utc::now(),
        }
    }

    pub fn id(mut self, id: String) -> EventBuilder {
        self.id = id;
        self
    }

    pub fn source(mut self, source: String) -> EventBuilder {
        self.source = source;
        self
    }

    pub fn timestamp(mut self, timestamp: DateTime<Utc>) -> EventBuilder {
        self.timestamp = timestamp;
        self
    }

    pub fn build(self, message: impl protobuf::MessageFull) -> Result<Vec<u8>, protobuf::Error> {
        let mut timestamp = Timestamp::new();
        timestamp.seconds = self.timestamp.naive_utc().timestamp();

        let mut time_attribute = CloudEventAttributeValue::new();
        time_attribute.set_ce_timestamp(timestamp);

        let message_bytes = message.write_to_bytes()?;
        let mut pb_any = Any::new();
        pb_any.value = message_bytes;
        pb_any.type_url = get_type_from_proto_message(&message);

        let mut event = CloudEvent::new();
        event.source = self.source;
        event.id = self.id;
        event.spec_version = "1.0".to_owned();
        event.type_ = get_type_from_proto_message(&message);
        event.attributes.insert("time".to_owned(), time_attribute);
        event.set_proto_data(pb_any);

        event.write_to_bytes()
    }
}

fn get_type_from_proto_message(message: &impl protobuf::MessageFull) -> String {
    message.descriptor_dyn().full_name().to_owned()
}

pub fn event_type_from_raw_bytes(src: &Vec<u8>) -> Result<String, protobuf::Error> {
    let event = CloudEvent::parse_from_bytes(src)?;
    Ok(event.type_)
}

pub fn event_data_from_event(src: &Vec<u8>, dst: &mut impl protobuf::MessageFull) -> Result<(), protobuf::Error> {
    let event = CloudEvent::parse_from_bytes(src)?;

    let cloud_any = event.proto_data();
    dst.merge_from_bytes(&cloud_any.value)?;
    Ok(())
}


#[cfg(test)]
mod tests {
    use chrono::{DateTime, Utc};
    use protobuf::Message;

    use super::{EventBuilder, event_type_from_raw_bytes, event_data_from_event};
    use crate::stubs::{cloudevent::CloudEvent, execution_started::ExecutionStarted};

    #[test]
    fn test_event_building_with_defaults() {
        let event_builder = EventBuilder::new();
        let mut message = ExecutionStarted::new();
        message.execution_id = "execution_id".to_owned();
        message.group_id = "group_id".to_owned();

        let event_bytes = event_builder.build(message).unwrap();

        let decoded_event = CloudEvent::parse_from_bytes(&event_bytes).unwrap();

        assert_eq!(
            decoded_event.source,
            "https://github.com/trento-project".to_owned()
        );
        assert_eq!(decoded_event.type_, "Trento.Checks.V1.ExecutionStarted");
        assert_ne!(decoded_event.id, "");
        assert_ne!(
            decoded_event
                .attributes
                .get("time")
                .unwrap()
                .ce_timestamp()
                .seconds,
            0
        );
    }

    #[test]
    fn test_event_building_with_custom_fields() {
        let custom_timestamp = DateTime::parse_from_rfc3339("2023-11-06T14:00:30.668Z")
            .unwrap()
            .with_timezone(&Utc);

        let event_builder = EventBuilder::new()
            .id("custom_id".to_owned())
            .source("custom_source".to_owned())
            .timestamp(custom_timestamp);

        let mut message = ExecutionStarted::new();
        message.execution_id = "execution_id".to_owned();
        message.group_id = "group_id".to_owned();

        let event_bytes = event_builder.build(message).unwrap();

        let decoded_event = CloudEvent::parse_from_bytes(&event_bytes).unwrap();

        assert_eq!(decoded_event.type_, "Trento.Checks.V1.ExecutionStarted");
        assert_eq!(decoded_event.source, "custom_source".to_owned());
        assert_eq!(decoded_event.id, "custom_id");
        assert_eq!(
            decoded_event
                .attributes
                .get("time")
                .unwrap()
                .ce_timestamp()
                .seconds,
            custom_timestamp.naive_utc().timestamp()
        );
    }

    #[test]
    fn test_event_type_from_raw_bytes(){
        let event_builder = EventBuilder::new();
        let mut message = ExecutionStarted::new();
        message.execution_id = "execution_id".to_owned();
        message.group_id = "group_id".to_owned();

        let event_bytes = event_builder.build(message).unwrap();

        assert_eq!("Trento.Checks.V1.ExecutionStarted", event_type_from_raw_bytes(&event_bytes).unwrap());
    }

    #[test]
    fn test_event_data_from_event(){
        let event_builder = EventBuilder::new();
        let mut message = ExecutionStarted::new();
        message.execution_id = "execution_id".to_owned();
        message.group_id = "group_id".to_owned();

        let event_bytes = event_builder.build(message).unwrap();

        let mut message_dst = ExecutionStarted::new();

        event_data_from_event(&event_bytes, &mut message_dst).unwrap();

        assert_eq!(message_dst.execution_id, "execution_id");
        assert_eq!(message_dst.group_id, "group_id");
    }

}
