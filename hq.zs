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

// Public interface ////////////////////////////////////////////////////////////////////////////////

  play
  void request() const
  {
    sendNetworkEvent("hq_go");
  }

  play
  void requestBack() const
  {
    sendNetworkEvent("hq_back");
  }

// Implementation //////////////////////////////////////////////////////////////////////////////////

  override
  void worldLoaded(WorldEvent event)
  {
    if (isHq())
    {
      level.nextmap = getBackmap();
    }
    else
    {
      requestRestorePlayerPosition();
      clearPositionString();
      clearBackmap();
    }
  }

  override
  void consoleProcess(ConsoleEvent event)
  {
    if      (event.name == "hq_request")      request();
    else if (event.name == "hq_request_back") requestBack();
  }

  override
  void networkProcess(ConsoleEvent event)
  {
    if      (event.name == "hq_go")   go();
    else if (event.name == "hq_back") back();
    else
    {
      Array<string> parts;
      event.name.split(parts, "@");
      if (parts[0] != "hq_restore_position") return;

      restorePlayerPosition(event.player, parts[1]);
    }
  }

// private: ////////////////////////////////////////////////////////////////////////////////////////

  private
  void requestRestorePlayerPosition()
  {
    string positionString = getPositionString();
    if (positionString.length() == 0) return;

    sendNetworkEvent(string.format("hq_restore_position@%s", positionString));
  }

  void restorePlayerPosition(int playerNumber, string positionString)
  {
    let positionDict = Dictionary.fromString(positionString);
    double x     = positionDict.at("x"    ).toDouble();
    double y     = positionDict.at("y"    ).toDouble();
    double z     = positionDict.at("z"    ).toDouble();
    double angle = positionDict.at("angle").toDouble();
    Actor player = players[playerNumber].mo;

    player.teleport((x, y, z), angle, TF_USESPOTZ);
  }

  private
  void go()
  {
    if (isHq()) return;

    Actor player = player();
    let positionDict = Dictionary.create();
    positionDict.insert("x",     string.format("%f", player.pos.x));
    positionDict.insert("y",     string.format("%f", player.pos.y));
    positionDict.insert("z",     string.format("%f", player.pos.z));
    positionDict.insert("angle", string.format("%f", player.angle));

    setPositionString(positionDict.toString());
    setBackmap(level.mapname);

    level.changeLevel(getHqMap(), 0, HQ_CHANGELEVEL_FLAGS);
  }

  private
  void back()
  {
    if (!isHq()) return;

    level.changeLevel(getBackmap(), 0, HQ_CHANGELEVEL_FLAGS);
  }

  private static
  string getPositionString()
  {
    let i = ThinkerIterator.create("hq_PositionStorage");
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
    let i = ThinkerIterator.create("hq_PositionStorage");
    Actor positionStorage;
    while (positionStorage = Actor(i.next()))
    {
      positionStorage.destroy();
    }
  }

  private static
  void setPositionString(string positionString)
  {
    hq_PositionStorage(Actor.spawn("hq_PositionStorage")).mPosition = positionString;
  }

  private static
  string getBackmap()
  {
    return hq_BackmapStorage(player().findInventory("hq_BackmapStorage")).mBackmap;
  }

  private static
  void setBackmap(string backmap)
  {
    hq_BackmapStorage(player().giveInventoryType("hq_BackmapStorage")).mBackmap = backmap;
  }

  private static
  void clearBackmap()
  {
    Actor backmapStorage = player().findInventory("hq_BackmapStorage");
    if (backmapStorage != NULL) backmapStorage.destroy();
  }

  private static
  PlayerPawn player()
  {
    return players[consolePlayer].mo;
  }

  private static
  bool isHq()
  {
    return level.mapname ~== HQ_MAP_NAME;
  }

  private static
  string getHqMap()
  {
    return HQ_MAP_NAME;
  }

  const HQ_MAP_NAME = "test";

  const HQ_CHANGELEVEL_FLAGS = CHANGELEVEL_NOINTERMISSION | CHANGELEVEL_PRERAISEWEAPON;

} // class hq_EventHandler
