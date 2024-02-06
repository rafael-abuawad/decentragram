import base64
import json


def decode_json(data_string):
    base64_data = data_string.split(";base64,")[1]
    decoded_bytes = base64.b64decode(base64_data)
    decoded_str = decoded_bytes.decode("utf-8")
    decoded_dict = json.loads(decoded_str)
    return decoded_dict


def test_make_a_post(sender, decentragram_post):
    # data
    image = "https://ipfs.io/ipfs/QmNf1UsmdGaMbpatQ6toXSkzDpizaGmC9zfunCyoz1enD5/penguin/99.png"
    description = "Pudgey penguin #99"

    # making a post
    decentragram_post.post(description, image, sender=sender)

    # getting and decoding that post
    post = decentragram_post.tokenURI(0)
    post = decode_json(post)

    assert post["image"] == image
    assert post["description"] == description

    attributes_likes = post["attributes"][0]
    assert attributes_likes["value"] == 0

    attributes_description = post["attributes"][1]
    assert attributes_description["value"] == description
