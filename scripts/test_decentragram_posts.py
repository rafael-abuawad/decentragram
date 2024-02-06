def test_make_a_post(sender, post):
    image = "https://ipfs.io/ipfs/QmNf1UsmdGaMbpatQ6toXSkzDpizaGmC9zfunCyoz1enD5/penguin/99.png"
    description = "Pudgey penguin #99"
    post.post(description, image, sender=sender)

    assert post.description(0) == description
    assert post.likes(0) == 0
    assert post.image(0) == image