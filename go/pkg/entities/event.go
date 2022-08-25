package entities

type TrentoEvent interface {
	Type() string
	Source() string
	SerializeCloudEvent() ([]byte, error)
	Valid() error
}
