class Fighter {
  final String name;
  final String role;
  final String image;
  final String distance;

  Fighter({
    required this.name,
    required this.role,
    required this.image,
    required this.distance,
  });

  static List<Fighter> getFighters() {
    return [
      Fighter(
        name: "Cedric Doumbe",
        role: "10 W - 2 L",
        image: "https://encrypted-tbn3.gstatic.com/images?q=tbn:ANd9GcQcnEzcSHVj-D8FavsquY3gaQXgCaezR3D6JpKoCCLPCFOWn1PV5Sb8vPACX41gig0UB-ILbK3X62KiHP58mu2i_g",
        distance: "2Km",
      ),
      Fighter(
        name: "Francis Ngannou",
        role: "14 W - 3 L",
        image: "https://encrypted-tbn3.gstatic.com/images?q=tbn:ANd9GcQVG17DlCgDoMuWZCirda0RYsEK-nCks-_2sMsWK9pZcSceEahyafll6OcsPBmMBwYx95gGdvk6ruhP1XzqWXcRag",
        distance: "100m",
      ),
      Fighter(
        name: "Hasbulla Magomedov",
        role: "1 W - 8 L",
        image: "https://static01.nyt.com/images/2023/04/20/fashion/20HASBULLA/20HASBULLA-videoSixteenByNineJumbo1600.jpg",
        distance: "30m",
      ),
      Fighter(
        name: "SDF du coin",
        role: "0 W - 20 L",
        image: "https://previews.123rf.com/images/bialasiewicz/bialasiewicz1405/bialasiewicz140500590/28344484-sdf-d%C3%A9pendance-%C3%A0-l-alcool-dans-la-rue.jpg",
        distance: "2m",
      ),
    ];
  }
}
