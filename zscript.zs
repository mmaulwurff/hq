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

  string mPositionString;

} // class hq_PositionStorage

class hq_EventHandler : EventHandler
{

  override void worldLoaded(WorldEvent event)
  {
    if (level.mapname ~== HQ_MAP_NAME)
    {
      level.nextmap = Cvar.GetCvar(BACKMAP_CVAR).getString();
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

        Actor player = players[consolePlayer].mo;
        player.Teleport((x, y, z), angle, TF_USESPOTZ);

        clearPositionString();
      }

      CVar.GetCvar(BACKMAP_CVAR).setString(level.mapname);
    }
  }

  override void networkProcess(ConsoleEvent event)
  {
    if (event.name == "go_to_hq")
    {
      if (level.mapname ~== HQ_MAP_NAME) return;

      Actor player = players[consolePlayer].mo;
      Dictionary positionDict = Dictionary.Create();
      positionDict.insert("x", string.Format("%f", player.pos.x));
      positionDict.insert("y", string.Format("%f", player.pos.y));
      positionDict.insert("z", string.Format("%f", player.pos.z));
      positionDict.insert("angle", string.Format("%f", player.angle));

      setPositionString(positionDict.toString());

      level.changeLevel(HQ_MAP_NAME, 0, HQ_CHANGELEVEL_FLAGS);
    }

    if (event.name == "go_back_from_hq" && level.mapname ~== HQ_MAP_NAME)
    {
      level.changeLevel(CVar.GetCvar(BACKMAP_CVAR).getString(), 0, HQ_CHANGELEVEL_FLAGS);
    }
  }

// private: ////////////////////////////////////////////////////////////////////////////////////////

  private
  string getPositionString()
  {
    ThinkerIterator i = ThinkerIterator.Create("hq_PositionStorage");
    hq_PositionStorage positionStorage;
    while (positionStorage = hq_PositionStorage(i.next()))
    {
      return positionStorage.mPositionString;
    }

    return "";
  }

  private
  void clearPositionString()
  {
    array<Actor> positionStorages;

    {
      ThinkerIterator i = ThinkerIterator.Create("hq_PositionStorage");
      Actor positionStorage;
      while (positionStorage = Actor(i.next()))
      {
        positionStorages.push(positionStorage);
      }
    }

    for (uint i = 0; i < positionStorages.size(); ++i)
    {
      positionStorages[i].destroy();
    }
  }

  private
  void setPositionString(string positionString)
  {
    let positionStorage = hq_PositionStorage(Actor.spawn("hq_PositionStorage"));
    positionStorage.mPositionString = positionString;
  }

  const HQ_MAP_NAME = "test";
  const BACKMAP_CVAR = "hq_backmap";

  const HQ_CHANGELEVEL_FLAGS = CHANGELEVEL_NOINTERMISSION | CHANGELEVEL_PRERAISEWEAPON;

} // class hq_EventHandler
