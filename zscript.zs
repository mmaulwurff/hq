version "4.5.0"

/* Copyright Alexander Kromm (mmaulwurff@gmail.com) 2020
 *
 * This file is part of Headquarters.
 *
 * Headquarters is free software: you can redistribute it and/or modify it under
 * the terms of the GNU General Public License as published by the Free Software
 * Foundation, either version 3 of the License, or (at your option) any later
 * version.
 *
 * Headquarters is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
 * details.
 *
 * You should have received a copy of the GNU General Public License along with
 * Headquarters.  If not, see <https://www.gnu.org/licenses/>.
 */

class hq_PositionStorage : Actor
{
  string mPosition;
}

class hq_BackmapStorage  : Inventory
{
  Default
  {
    +Inventory.Undroppable;
    +inventory.Untossable;
    +inventory.Unclearable;
  }

  string mBackmap;
}

class hq_EventHandler : EventHandler
{

  override
  void worldLoaded(WorldEvent event)
  {
    if (level.mapname ~== HQ_MAP_NAME)
    {
      level.nextmap = getBackmap();
    }
    else
    {
      string positionString = getPositionString();
      if (positionString.length() != 0)
      {
        Dictionary positionDict = Dictionary.fromString(positionString);
        double x = positionDict.at("x").toDouble();
        double y = positionDict.at("y").toDouble();
        double z = positionDict.at("z").toDouble();
        double angle = positionDict.at("angle").toDouble();

        player().Teleport((x, y, z), angle, TF_USESPOTZ);

        clearPositionString();
        clearBackmap();
      }
    }
  }

  override
  void networkProcess(ConsoleEvent event)
  {
    if (event.name == "go_to_hq")
    {
      if (level.mapname ~== HQ_MAP_NAME) return;

      Actor player = player();
      Dictionary positionDict = Dictionary.Create();
      positionDict.insert("x", string.Format("%f", player.pos.x));
      positionDict.insert("y", string.Format("%f", player.pos.y));
      positionDict.insert("z", string.Format("%f", player.pos.z));
      positionDict.insert("angle", string.Format("%f", player.angle));

      setPositionString(positionDict.toString());
      setBackmap(level.mapname);

      level.changeLevel(HQ_MAP_NAME, 0, HQ_CHANGELEVEL_FLAGS);
    }

    if (event.name == "go_back_from_hq" && level.mapname ~== HQ_MAP_NAME)
    {
      level.changeLevel(getBackmap(), 0, HQ_CHANGELEVEL_FLAGS);
    }
  }

// private: ////////////////////////////////////////////////////////////////////////////////////////

  private static
  string getPositionString()
  {
    ThinkerIterator i = ThinkerIterator.Create("hq_PositionStorage");
    hq_PositionStorage positionStorage;
    while (positionStorage = hq_PositionStorage(i.next()))
    {
      return positionStorage.mPosition;
    }

    return "";
  }

  private static
  void clearPositionString()
  {
    ThinkerIterator i = ThinkerIterator.Create("hq_PositionStorage");
    Actor positionStorage;
    while (positionStorage = Actor(i.next()))
    {
      positionStorage.destroy();
    }
  }

  private static
  void setPositionString(string positionString)
  {
    let positionStorage = hq_PositionStorage(Actor.spawn("hq_PositionStorage"));
    positionStorage.mPosition = positionString;
  }

  private static
  string getBackmap()
  {
    let backmapStorage = hq_BackmapStorage(player().findInventory("hq_BackmapStorage"));
    return backmapStorage.mBackmap;
  }

  private static
  void setBackmap(string backmap)
  {
    let backmapStorage = hq_BackmapStorage(player().giveInventoryType("hq_BackmapStorage"));
    backmapStorage.mBackmap = backmap;
  }

  private static
  void clearBackmap()
  {
    player().findInventory("hq_BackmapStorage").destroy();
  }

  private static
  PlayerPawn player()
  {
    return players[consolePlayer].mo;
  }

  const HQ_MAP_NAME = "test";

  const HQ_CHANGELEVEL_FLAGS = CHANGELEVEL_NOINTERMISSION | CHANGELEVEL_PRERAISEWEAPON;

} // class hq_EventHandler
